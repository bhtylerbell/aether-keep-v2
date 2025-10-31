-- =============================================
-- Aether Keep v2 - Initial Database Schema
-- =============================================
-- This migration creates all tables, indexes, RLS policies,
-- triggers, and helper functions for the application.
--
-- Run this in Supabase SQL Editor or via migrations
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- HELPER FUNCTIONS & TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- USER IDENTITY & PROFILES
-- =============================================

-- Profiles Table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_email ON profiles(email);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Trigger to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', '')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Site Admins Table
CREATE TABLE site_admins (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  granted_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_site_admins_role ON site_admins(role);

ALTER TABLE site_admins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view site_admins"
  ON site_admins FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM site_admins sa
      WHERE sa.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage site_admins"
  ON site_admins FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM site_admins sa
      WHERE sa.user_id = auth.uid()
        AND sa.role = 'admin'
    )
  );

-- =============================================
-- CAMPAIGNS
-- =============================================

-- Campaigns Table
CREATE TABLE campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  is_public BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_campaigns_created_by ON campaigns(created_by);
CREATE INDEX idx_campaigns_is_archived ON campaigns(is_archived);
CREATE INDEX idx_campaigns_created_at ON campaigns(created_at DESC);

ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER update_campaigns_updated_at
  BEFORE UPDATE ON campaigns
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Campaign Members Table
CREATE TABLE campaign_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'gm', 'player')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(campaign_id, user_id)
);

CREATE INDEX idx_campaign_members_campaign_id ON campaign_members(campaign_id);
CREATE INDEX idx_campaign_members_user_id ON campaign_members(user_id);
CREATE INDEX idx_campaign_members_role ON campaign_members(role);

ALTER TABLE campaign_members ENABLE ROW LEVEL SECURITY;

-- Trigger to auto-add creator as owner
CREATE OR REPLACE FUNCTION add_campaign_owner()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO campaign_members (campaign_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'owner');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_campaign_created
  AFTER INSERT ON campaigns
  FOR EACH ROW
  EXECUTE FUNCTION add_campaign_owner();

-- RLS Policies for Campaigns
CREATE POLICY "Members can view campaigns"
  ON campaigns FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaigns.id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create campaigns"
  ON campaigns FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Owners and GMs can update campaigns"
  ON campaigns FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaigns.id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

CREATE POLICY "Owners can delete campaigns"
  ON campaigns FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaigns.id
        AND cm.user_id = auth.uid()
        AND cm.role = 'owner'
    )
  );

-- RLS Policies for Campaign Members
CREATE POLICY "Members can view campaign membership"
  ON campaign_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_members.campaign_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Owners and GMs can manage members"
  ON campaign_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_members.campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

-- Campaign Invitations Table
CREATE TABLE campaign_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  invited_by UUID NOT NULL REFERENCES auth.users(id),
  invited_email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('gm', 'player')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
  token UUID DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days'
);

CREATE INDEX idx_campaign_invitations_campaign_id ON campaign_invitations(campaign_id);
CREATE INDEX idx_campaign_invitations_invited_email ON campaign_invitations(invited_email);
CREATE INDEX idx_campaign_invitations_token ON campaign_invitations(token);
CREATE INDEX idx_campaign_invitations_status ON campaign_invitations(status);

ALTER TABLE campaign_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Campaign members can view invitations"
  ON campaign_invitations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_invitations.campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
    OR
    invited_email = (SELECT email FROM auth.users WHERE id = auth.uid())
  );

CREATE POLICY "Owners and GMs can create invitations"
  ON campaign_invitations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

-- =============================================
-- SESSIONS
-- =============================================

-- Sessions Table
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  session_number INTEGER,
  scheduled_at TIMESTAMPTZ,
  duration_minutes INTEGER,
  location TEXT,
  platform TEXT,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled')),
  recap TEXT,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sessions_campaign_id ON sessions(campaign_id);
CREATE INDEX idx_sessions_scheduled_at ON sessions(scheduled_at);
CREATE INDEX idx_sessions_status ON sessions(status);
CREATE INDEX idx_sessions_session_number ON sessions(campaign_id, session_number);

ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Campaign members can view sessions"
  ON sessions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = sessions.campaign_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Owners and GMs can manage sessions"
  ON sessions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = sessions.campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

CREATE TRIGGER update_sessions_updated_at
  BEFORE UPDATE ON sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Session Attendance Table
CREATE TABLE session_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'attending', 'absent', 'tentative')),
  notes TEXT,
  UNIQUE(session_id, user_id)
);

CREATE INDEX idx_session_attendance_session_id ON session_attendance(session_id);
CREATE INDEX idx_session_attendance_user_id ON session_attendance(user_id);

ALTER TABLE session_attendance ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Campaign members can view attendance"
  ON session_attendance FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM sessions s
      JOIN campaign_members cm ON cm.campaign_id = s.campaign_id
      WHERE s.id = session_attendance.session_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own attendance"
  ON session_attendance FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "GMs can manage attendance"
  ON session_attendance FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM sessions s
      JOIN campaign_members cm ON cm.campaign_id = s.campaign_id
      WHERE s.id = session_attendance.session_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

-- =============================================
-- CHARACTERS
-- =============================================

-- Characters Table
CREATE TABLE characters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  race TEXT,
  class TEXT,
  level INTEGER DEFAULT 1,
  description TEXT,
  avatar_url TEXT,
  stats JSONB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_characters_campaign_id ON characters(campaign_id);
CREATE INDEX idx_characters_player_id ON characters(player_id);
CREATE INDEX idx_characters_is_active ON characters(is_active);

ALTER TABLE characters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Campaign members can view characters"
  ON characters FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = characters.campaign_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Players can create own characters"
  ON characters FOR INSERT
  WITH CHECK (
    player_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Players can update own characters"
  ON characters FOR UPDATE
  USING (player_id = auth.uid());

CREATE POLICY "GMs can manage all characters"
  ON characters FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = characters.campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

CREATE TRIGGER update_characters_updated_at
  BEFORE UPDATE ON characters
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- NOTES
-- =============================================

-- Notes Table
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  visibility TEXT DEFAULT 'private' CHECK (visibility IN ('private', 'shared', 'gm_only')),
  author_id UUID NOT NULL REFERENCES auth.users(id),
  parent_id UUID REFERENCES notes(id) ON DELETE CASCADE,
  session_id UUID REFERENCES sessions(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notes_campaign_id ON notes(campaign_id);
CREATE INDEX idx_notes_author_id ON notes(author_id);
CREATE INDEX idx_notes_visibility ON notes(visibility);
CREATE INDEX idx_notes_parent_id ON notes(parent_id);
CREATE INDEX idx_notes_session_id ON notes(session_id);

ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authors can view own notes"
  ON notes FOR SELECT
  USING (author_id = auth.uid());

CREATE POLICY "Shared notes visible to campaign members"
  ON notes FOR SELECT
  USING (
    visibility = 'shared'
    AND EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = notes.campaign_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "GM notes visible to GMs"
  ON notes FOR SELECT
  USING (
    visibility = 'gm_only'
    AND EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = notes.campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

CREATE POLICY "Users can create notes in their campaigns"
  ON notes FOR INSERT
  WITH CHECK (
    author_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Authors can update own notes"
  ON notes FOR UPDATE
  USING (author_id = auth.uid());

CREATE POLICY "Authors can delete own notes"
  ON notes FOR DELETE
  USING (author_id = auth.uid());

CREATE TRIGGER update_notes_updated_at
  BEFORE UPDATE ON notes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- WORLDS
-- =============================================

-- Worlds Table
CREATE TABLE worlds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  is_public BOOLEAN DEFAULT FALSE,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_worlds_created_by ON worlds(created_by);
CREATE INDEX idx_worlds_is_public ON worlds(is_public);
CREATE INDEX idx_worlds_created_at ON worlds(created_at DESC);

ALTER TABLE worlds ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER update_worlds_updated_at
  BEFORE UPDATE ON worlds
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- World Members Table
CREATE TABLE world_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  world_id UUID NOT NULL REFERENCES worlds(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'editor', 'viewer')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(world_id, user_id)
);

CREATE INDEX idx_world_members_world_id ON world_members(world_id);
CREATE INDEX idx_world_members_user_id ON world_members(user_id);
CREATE INDEX idx_world_members_role ON world_members(role);

ALTER TABLE world_members ENABLE ROW LEVEL SECURITY;

-- Trigger to auto-add creator as owner
CREATE OR REPLACE FUNCTION add_world_owner()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO world_members (world_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'owner');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_world_created
  AFTER INSERT ON worlds
  FOR EACH ROW
  EXECUTE FUNCTION add_world_owner();

-- RLS Policies for Worlds
CREATE POLICY "Members can view worlds"
  ON worlds FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = worlds.id
        AND wm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create worlds"
  ON worlds FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Owners and editors can update worlds"
  ON worlds FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = worlds.id
        AND wm.user_id = auth.uid()
        AND wm.role IN ('owner', 'editor')
    )
  );

CREATE POLICY "Owners can delete worlds"
  ON worlds FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = worlds.id
        AND wm.user_id = auth.uid()
        AND wm.role = 'owner'
    )
  );

-- RLS Policies for World Members
CREATE POLICY "Members can view world membership"
  ON world_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = world_members.world_id
        AND wm.user_id = auth.uid()
    )
  );

CREATE POLICY "Owners can manage members"
  ON world_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = world_members.world_id
        AND wm.user_id = auth.uid()
        AND wm.role = 'owner'
    )
  );

-- Campaign-World Linking Table
CREATE TABLE campaign_worlds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  world_id UUID NOT NULL REFERENCES worlds(id) ON DELETE CASCADE,
  linked_at TIMESTAMPTZ DEFAULT NOW(),
  linked_by UUID NOT NULL REFERENCES auth.users(id),
  UNIQUE(campaign_id, world_id)
);

CREATE INDEX idx_campaign_worlds_campaign_id ON campaign_worlds(campaign_id);
CREATE INDEX idx_campaign_worlds_world_id ON campaign_worlds(world_id);

ALTER TABLE campaign_worlds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Campaign and world members can view links"
  ON campaign_worlds FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_worlds.campaign_id
        AND cm.user_id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = campaign_worlds.world_id
        AND wm.user_id = auth.uid()
    )
  );

CREATE POLICY "Campaign owners and GMs can manage links"
  ON campaign_worlds FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_worlds.campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

-- =============================================
-- SYSTEMS
-- =============================================

-- Systems Table
CREATE TABLE systems (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  is_public BOOLEAN DEFAULT FALSE,
  is_predefined BOOLEAN DEFAULT FALSE,
  is_template BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_systems_created_by ON systems(created_by);
CREATE INDEX idx_systems_is_public ON systems(is_public);
CREATE INDEX idx_systems_is_predefined ON systems(is_predefined);
CREATE INDEX idx_systems_is_template ON systems(is_template);
CREATE INDEX idx_systems_created_at ON systems(created_at DESC);

ALTER TABLE systems ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER update_systems_updated_at
  BEFORE UPDATE ON systems
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- System Members Table
CREATE TABLE system_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  system_id UUID NOT NULL REFERENCES systems(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'editor', 'viewer')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(system_id, user_id)
);

CREATE INDEX idx_system_members_system_id ON system_members(system_id);
CREATE INDEX idx_system_members_user_id ON system_members(user_id);
CREATE INDEX idx_system_members_role ON system_members(role);

ALTER TABLE system_members ENABLE ROW LEVEL SECURITY;

-- Trigger to auto-add creator as owner
CREATE OR REPLACE FUNCTION add_system_owner()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_predefined = FALSE AND NEW.created_by IS NOT NULL THEN
    INSERT INTO system_members (system_id, user_id, role)
    VALUES (NEW.id, NEW.created_by, 'owner');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_system_created
  AFTER INSERT ON systems
  FOR EACH ROW
  EXECUTE FUNCTION add_system_owner();

-- RLS Policies for Systems
CREATE POLICY "Everyone can view predefined systems"
  ON systems FOR SELECT
  USING (is_predefined = TRUE);

CREATE POLICY "Members can view systems"
  ON systems FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = systems.id
        AND sm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create systems"
  ON systems FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Owners and editors can update systems"
  ON systems FOR UPDATE
  USING (
    is_predefined = FALSE
    AND EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = systems.id
        AND sm.user_id = auth.uid()
        AND sm.role IN ('owner', 'editor')
    )
  );

CREATE POLICY "Owners can delete systems"
  ON systems FOR DELETE
  USING (
    is_predefined = FALSE
    AND EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = systems.id
        AND sm.user_id = auth.uid()
        AND sm.role = 'owner'
    )
  );

-- RLS Policies for System Members
CREATE POLICY "Members can view system membership"
  ON system_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = system_members.system_id
        AND sm.user_id = auth.uid()
    )
  );

CREATE POLICY "Owners can manage members"
  ON system_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = system_members.system_id
        AND sm.user_id = auth.uid()
        AND sm.role = 'owner'
    )
  );

-- Campaign-System Linking Table
CREATE TABLE campaign_systems (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  system_id UUID NOT NULL REFERENCES systems(id) ON DELETE CASCADE,
  linked_at TIMESTAMPTZ DEFAULT NOW(),
  linked_by UUID NOT NULL REFERENCES auth.users(id),
  UNIQUE(campaign_id, system_id)
);

CREATE INDEX idx_campaign_systems_campaign_id ON campaign_systems(campaign_id);
CREATE INDEX idx_campaign_systems_system_id ON campaign_systems(system_id);

ALTER TABLE campaign_systems ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Campaign and system members can view links"
  ON campaign_systems FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_systems.campaign_id
        AND cm.user_id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = campaign_systems.system_id
        AND sm.user_id = auth.uid()
    )
  );

CREATE POLICY "Campaign owners and GMs can manage links"
  ON campaign_systems FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM campaign_members cm
      WHERE cm.campaign_id = campaign_systems.campaign_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'gm')
    )
  );

-- =============================================
-- CATEGORIES
-- =============================================

-- Categories Table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  world_id UUID REFERENCES worlds(id) ON DELETE CASCADE,
  system_id UUID REFERENCES systems(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  icon TEXT,
  description TEXT,
  is_predefined BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (
    (world_id IS NOT NULL AND system_id IS NULL) OR
    (world_id IS NULL AND system_id IS NOT NULL)
  )
);

CREATE INDEX idx_categories_world_id ON categories(world_id);
CREATE INDEX idx_categories_system_id ON categories(system_id);
CREATE INDEX idx_categories_slug ON categories(slug);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "World members can view categories"
  ON categories FOR SELECT
  USING (
    world_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = categories.world_id
        AND wm.user_id = auth.uid()
    )
  );

CREATE POLICY "System members can view categories"
  ON categories FOR SELECT
  USING (
    system_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = categories.system_id
        AND sm.user_id = auth.uid()
    )
  );

CREATE POLICY "Owners and editors can manage world categories"
  ON categories FOR ALL
  USING (
    world_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = categories.world_id
        AND wm.user_id = auth.uid()
        AND wm.role IN ('owner', 'editor')
    )
  );

CREATE POLICY "Owners and editors can manage system categories"
  ON categories FOR ALL
  USING (
    system_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = categories.system_id
        AND sm.user_id = auth.uid()
        AND sm.role IN ('owner', 'editor')
    )
  );

-- =============================================
-- PAGES
-- =============================================

-- Pages Table
CREATE TABLE pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  world_id UUID REFERENCES worlds(id) ON DELETE CASCADE,
  system_id UUID REFERENCES systems(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  parent_id UUID REFERENCES pages(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  icon TEXT,
  content TEXT,
  sort_order INTEGER DEFAULT 0,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (
    (world_id IS NOT NULL AND system_id IS NULL) OR
    (world_id IS NULL AND system_id IS NOT NULL)
  )
);

CREATE INDEX idx_pages_world_id ON pages(world_id);
CREATE INDEX idx_pages_system_id ON pages(system_id);
CREATE INDEX idx_pages_category_id ON pages(category_id);
CREATE INDEX idx_pages_parent_id ON pages(parent_id);
CREATE INDEX idx_pages_created_by ON pages(created_by);

ALTER TABLE pages ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER update_pages_updated_at
  BEFORE UPDATE ON pages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies for Pages
CREATE POLICY "World members can view pages"
  ON pages FOR SELECT
  USING (
    world_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = pages.world_id
        AND wm.user_id = auth.uid()
    )
  );

CREATE POLICY "System members can view pages"
  ON pages FOR SELECT
  USING (
    system_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = pages.system_id
        AND sm.user_id = auth.uid()
    )
  );

CREATE POLICY "Campaign members can view linked world pages"
  ON pages FOR SELECT
  USING (
    world_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM campaign_worlds cw
      JOIN campaign_members cm ON cm.campaign_id = cw.campaign_id
      WHERE cw.world_id = pages.world_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Campaign members can view linked system pages"
  ON pages FOR SELECT
  USING (
    system_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM campaign_systems cs
      JOIN campaign_members cm ON cm.campaign_id = cs.campaign_id
      WHERE cs.system_id = pages.system_id
        AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "World editors can manage pages"
  ON pages FOR ALL
  USING (
    world_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = pages.world_id
        AND wm.user_id = auth.uid()
        AND wm.role IN ('owner', 'editor')
    )
  );

CREATE POLICY "System editors can manage pages"
  ON pages FOR ALL
  USING (
    system_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = pages.system_id
        AND sm.user_id = auth.uid()
        AND sm.role IN ('owner', 'editor')
    )
  );

-- =============================================
-- CUSTOM FIELDS
-- =============================================

-- Custom Fields Table
CREATE TABLE custom_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id UUID NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  field_name TEXT NOT NULL,
  field_type TEXT NOT NULL CHECK (
    field_type IN (
      'text', 'textarea', 'rich_text', 'number', 'date',
      'select', 'multi_select', 'checkbox', 'url', 'email',
      'relation', 'file', 'dice_notation', 'formula'
    )
  ),
  field_config JSONB,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_custom_fields_page_id ON custom_fields(page_id);

ALTER TABLE custom_fields ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Inherit permissions from page"
  ON custom_fields FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pages p
      WHERE p.id = custom_fields.page_id
    )
  );

CREATE POLICY "Page editors can manage custom fields"
  ON custom_fields FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM pages p
      LEFT JOIN world_members wm ON wm.world_id = p.world_id
      LEFT JOIN system_members sm ON sm.system_id = p.system_id
      WHERE p.id = custom_fields.page_id
        AND (
          (wm.user_id = auth.uid() AND wm.role IN ('owner', 'editor'))
          OR
          (sm.user_id = auth.uid() AND sm.role IN ('owner', 'editor'))
        )
    )
  );

-- Field Values Table
CREATE TABLE field_values (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_id UUID NOT NULL REFERENCES custom_fields(id) ON DELETE CASCADE,
  page_id UUID NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  value JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(field_id, page_id)
);

CREATE INDEX idx_field_values_field_id ON field_values(field_id);
CREATE INDEX idx_field_values_page_id ON field_values(page_id);

ALTER TABLE field_values ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Inherit permissions from page"
  ON field_values FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pages p
      WHERE p.id = field_values.page_id
    )
  );

CREATE POLICY "Page editors can manage field values"
  ON field_values FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM pages p
      LEFT JOIN world_members wm ON wm.world_id = p.world_id
      LEFT JOIN system_members sm ON sm.system_id = p.system_id
      WHERE p.id = field_values.page_id
        AND (
          (wm.user_id = auth.uid() AND wm.role IN ('owner', 'editor'))
          OR
          (sm.user_id = auth.uid() AND sm.role IN ('owner', 'editor'))
        )
    )
  );

CREATE TRIGGER update_field_values_updated_at
  BEFORE UPDATE ON field_values
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- TAGS
-- =============================================

-- Tags Table
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  world_id UUID REFERENCES worlds(id) ON DELETE CASCADE,
  system_id UUID REFERENCES systems(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (
    (world_id IS NOT NULL AND system_id IS NULL) OR
    (world_id IS NULL AND system_id IS NOT NULL)
  )
);

CREATE INDEX idx_tags_world_id ON tags(world_id);
CREATE INDEX idx_tags_system_id ON tags(system_id);
CREATE INDEX idx_tags_name ON tags(name);

ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Inherit permissions from world/system"
  ON tags FOR SELECT
  USING (
    (world_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM world_members wm
      WHERE wm.world_id = tags.world_id
        AND wm.user_id = auth.uid()
    ))
    OR
    (system_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM system_members sm
      WHERE sm.system_id = tags.system_id
        AND sm.user_id = auth.uid()
    ))
  );

-- Page Tags Junction Table
CREATE TABLE page_tags (
  page_id UUID NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (page_id, tag_id)
);

CREATE INDEX idx_page_tags_page_id ON page_tags(page_id);
CREATE INDEX idx_page_tags_tag_id ON page_tags(tag_id);

ALTER TABLE page_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Inherit permissions from page"
  ON page_tags FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pages p
      WHERE p.id = page_tags.page_id
    )
  );

-- =============================================
-- PAGE VERSIONS
-- =============================================

-- Page Versions Table
CREATE TABLE page_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id UUID NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  version_number INTEGER NOT NULL,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_page_versions_page_id ON page_versions(page_id);
CREATE INDEX idx_page_versions_created_at ON page_versions(page_id, created_at DESC);

ALTER TABLE page_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Inherit permissions from page"
  ON page_versions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pages p
      WHERE p.id = page_versions.page_id
    )
  );

-- =============================================
-- NOTIFICATIONS
-- =============================================

-- Notifications Table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (
    type IN (
      'session_reminder', 'campaign_invite', 'world_invite', 'system_invite',
      'mention', 'comment', 'share', 'system_update'
    )
  ),
  title TEXT NOT NULL,
  message TEXT,
  link_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created_at ON notifications(user_id, created_at DESC);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "System can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (TRUE);

-- =============================================
-- PERMISSION HELPER FUNCTIONS
-- =============================================

-- Check if user has specific role in campaign
CREATE OR REPLACE FUNCTION user_has_campaign_role(
  p_campaign_id UUID,
  p_user_id UUID,
  p_roles TEXT[]
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM campaign_members
    WHERE campaign_id = p_campaign_id
      AND user_id = p_user_id
      AND role = ANY(p_roles)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has specific role in world
CREATE OR REPLACE FUNCTION user_has_world_role(
  p_world_id UUID,
  p_user_id UUID,
  p_roles TEXT[]
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM world_members
    WHERE world_id = p_world_id
      AND user_id = p_user_id
      AND role = ANY(p_roles)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has specific role in system
CREATE OR REPLACE FUNCTION user_has_system_role(
  p_system_id UUID,
  p_user_id UUID,
  p_roles TEXT[]
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM system_members
    WHERE system_id = p_system_id
      AND user_id = p_user_id
      AND role = ANY(p_roles)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is a site admin
CREATE OR REPLACE FUNCTION user_is_site_admin(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM site_admins
    WHERE user_id = p_user_id
      AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- FULL-TEXT SEARCH SETUP
-- =============================================

-- Add search vector column to pages
ALTER TABLE pages ADD COLUMN search_vector tsvector;

-- Create index for full-text search on pages
CREATE INDEX idx_pages_search_vector ON pages USING gin(search_vector);

-- Function to update search vector for pages
CREATE OR REPLACE FUNCTION pages_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update search vector for pages
CREATE TRIGGER pages_search_vector_update_trigger
  BEFORE INSERT OR UPDATE ON pages
  FOR EACH ROW
  EXECUTE FUNCTION pages_search_vector_update();

-- Add search vector column to notes
ALTER TABLE notes ADD COLUMN search_vector tsvector;

-- Create index for full-text search on notes
CREATE INDEX idx_notes_search_vector ON notes USING gin(search_vector);

-- Function to update search vector for notes
CREATE OR REPLACE FUNCTION notes_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update search vector for notes
CREATE TRIGGER notes_search_vector_update_trigger
  BEFORE INSERT OR UPDATE ON notes
  FOR EACH ROW
  EXECUTE FUNCTION notes_search_vector_update();

-- =============================================
-- MIGRATION COMPLETE
-- =============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO postgres, anon, authenticated, service_role;
