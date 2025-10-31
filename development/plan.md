# Development Plan

## Overview

This plan breaks down the Aether Keep v2 development roadmap into actionable tasks, organized by phase. Each task is designed to build upon the previous ones, with early focus on foundational infrastructure (auth, database, core UI) before implementing feature-specific functionality.

---

## Phase 1: Foundation & Infrastructure

### 1.1 Environment & Dependencies Setup

- [x] Install and configure Supabase CLI for local development
- [x] Create Supabase project (production and staging environments)
- [x] Set up environment variables (`.env.local`) for Supabase credentials
- [x] Install core dependencies:
  - [x] `@supabase/supabase-js`, `@supabase/auth-helpers-nextjs`, `@supabase/ssr`
  - [x] `@tanstack/react-query` for data fetching
  - [x] `react-hook-form`, `zod`, `@hookform/resolvers` for forms
  - [x] `date-fns` for date utilities
  - [x] `clsx`, `tailwind-merge` for styling utilities
- [x] Install UI dependencies:
  - [x] `@headlessui/react` for accessible components
  - [x] `@heroicons/react` for icons
  - [x] `sonner` for notifications
  - [x] `nprogress` for loading indicators
- [x] Install security dependencies:
  - [x] `dompurify`, `isomorphic-dompurify` for XSS protection
  - [x] `validator` for input validation
- [x] Configure TypeScript path aliases (verify `@/*` works correctly)
- [x] Set up ESLint and Prettier with project-specific rules

### 1.2 Database Schema Design

- [ ] Design core database schema (see `database.md` when ready)
- [ ] Create `users` table schema (extends Supabase auth.users)
- [ ] Create `profiles` table for user metadata
- [ ] Create `campaigns` table with ownership and metadata
- [ ] Create `campaign_members` junction table with roles
- [ ] Create `campaign_worlds` junction table (campaign to world linking)
- [ ] Create `campaign_systems` junction table (campaign to system linking)
- [ ] Create `worlds` table with ownership and metadata
- [ ] Create `world_members` junction table with roles
- [ ] Create `systems` table with ownership and metadata
- [ ] Create `system_members` junction table with roles
- [ ] Create `predefined_systems` table for official systems (D&D 5e, Pathfinder 2e, etc.)
- [ ] Create `pages` table for hierarchical content (used by worlds and systems)
- [ ] Create `page_versions` table for version history
- [ ] Create `categories` table for organizing pages
- [ ] Create `custom_fields` table for flexible entry structures
- [ ] Create `field_values` table for storing custom field data
- [ ] Create `tags` table for metadata
- [ ] Create `sessions` table for campaign session tracking
- [ ] Create `characters` table for campaign characters
- [ ] Create `notes` table for campaign notes with visibility levels
- [ ] Set up database indexes for performance
- [ ] Document all table schemas in `database.md`

### 1.3 Row Level Security (RLS) Policies

- [ ] Enable RLS on all tables
- [ ] Create RLS policies for `profiles` (users can read own profile)
- [ ] Create RLS policies for `campaigns` (owner has full access)
- [ ] Create RLS policies for `campaign_members` (access based on membership)
- [ ] Create RLS policies for `campaign_worlds` (manage world linking)
- [ ] Create RLS policies for `campaign_systems` (manage system linking)
- [ ] Create RLS policies for `worlds` (owner and members based on role)
- [ ] Create RLS policies for `world_members` (manage access control)
- [ ] Create RLS policies for `systems` (owner and members based on role)
- [ ] Create RLS policies for `system_members` (manage access control)
- [ ] Create RLS policies for `predefined_systems` (read-only for all users)
- [ ] Create RLS policies for world/system content access via campaigns:
  - [ ] Campaign members can read linked world content
  - [ ] Campaign members can read linked system content
- [ ] Create RLS policies for `pages` (inherit from parent resource)
- [ ] Create RLS policies for `notes` (based on visibility settings)
- [ ] Create RLS policies for `sessions` (campaign members only)
- [ ] Create RLS policies for `characters` (campaign members and owner)
- [ ] Test all RLS policies with different user scenarios
- [ ] Document security model in `database.md`

### 1.4 Supabase Storage Setup

- [ ] Create storage buckets:
  - [ ] `avatars` bucket for user profile images
  - [ ] `campaign-assets` bucket for campaign files
  - [ ] `world-assets` bucket for world building media
  - [ ] `system-assets` bucket for system building media
- [ ] Configure bucket policies and access rules
- [ ] Set up file size limits and allowed file types
- [ ] Create helper functions for secure file uploads
- [ ] Implement file type validation utilities

### 1.5 Authentication System

- [x] Create Supabase client utility (`lib/supabase/client.ts`)
- [x] Create server-side Supabase client (`lib/supabase/server.ts`)
- [x] Set up middleware for auth protection (`middleware.ts`)
- [x] Create auth callback route (`app/auth/callback/route.ts`)
- [x] Create sign-in page (`app/(auth)/sign-in/page.tsx`)
  - [x] Email/password sign-in form
  - [ ] OAuth providers (Google, Discord - optional)
  - [x] Form validation with Zod
  - [x] Error handling and user feedback
  - [x] "Forgot password" link
- [x] Create sign-up page (`app/(auth)/sign-up/page.tsx`)
  - [x] Email/password registration form
  - [x] Form validation (email, password strength)
  - [ ] Terms of service checkbox
  - [x] Auto-redirect after successful registration
- [x] Create password reset page (`app/(auth)/reset-password/page.tsx`)
  - [x] Request reset email form
  - [x] Reset password form (with token)
  - [x] Confirmation and redirect
- [ ] Create email verification page (`app/(auth)/verify-email/page.tsx`)
  - [ ] Email verification confirmation
  - [ ] Resend verification email option
- [x] Implement auth hooks:
  - [x] `useUser()` hook for current user
  - [x] `useSession()` hook for session data
  - [x] `useAuth()` hook for auth actions (sign in, sign out, etc.)
- [x] Create protected route wrapper component
- [x] Test authentication flow end-to-end
- [ ] Set up email templates in Supabase (welcome, reset password, verify email)

### 1.6 Core UI Components Library

- [ ] Create layout components:
  - [ ] `<AppLayout>` - Main authenticated app layout
  - [ ] `<Sidebar>` - Collapsible navigation sidebar
  - [ ] `<Header>` - Top navigation bar with user menu
  - [ ] `<Footer>` - App footer component
- [ ] Create form components:
  - [ ] `<Input>` - Text input with validation states
  - [ ] `<Textarea>` - Multiline text input
  - [ ] `<Select>` - Dropdown select component
  - [ ] `<Checkbox>` - Checkbox with label
  - [ ] `<RadioGroup>` - Radio button group
  - [ ] `<DatePicker>` - Date selection component
  - [ ] `<FormField>` - Wrapper for form fields with labels and errors
- [ ] Create feedback components:
  - [ ] `<Button>` - Primary, secondary, danger variants
  - [ ] `<Alert>` - Info, success, warning, error alerts
  - [ ] `<Toast>` - Notification toast system integration
  - [ ] `<Modal>` - Dialog/modal component
  - [ ] `<ConfirmDialog>` - Confirmation dialog
  - [ ] `<LoadingSpinner>` - Loading state indicator
  - [ ] `<Skeleton>` - Loading skeleton screens
- [ ] Create navigation components:
  - [ ] `<Tabs>` - Tab navigation
  - [ ] `<Breadcrumbs>` - Breadcrumb navigation
  - [ ] `<Pagination>` - Page navigation
  - [ ] `<Dropdown>` - Dropdown menu
- [ ] Create data display components:
  - [ ] `<Card>` - Content card container
  - [ ] `<Avatar>` - User avatar with fallback
  - [ ] `<Badge>` - Label badge component
  - [ ] `<EmptyState>` - Empty state placeholder
  - [ ] `<ErrorBoundary>` - Error boundary component
- [ ] Document all components with usage examples
- [ ] Create Storybook or component showcase page (optional)

### 1.7 Utility Functions & Helpers

- [ ] Create database query helpers (`lib/db/queries.ts`)
- [ ] Create error handling utilities (`lib/errors.ts`)
- [ ] Create input sanitization functions (`lib/security.ts`)
- [ ] Create date formatting helpers (`lib/date.ts`)
- [ ] Create permission checking utilities (`lib/permissions.ts`)
- [ ] Create file upload helpers (`lib/upload.ts`)
- [ ] Create notification utility wrapper (`lib/notifications.ts`)
- [ ] Create validation schemas library (`lib/validations/`)
- [ ] Set up API error response types
- [ ] Create server action wrapper with error handling

### 1.8 User Profile & Settings

- [ ] Create profile page (`app/(app)/profile/page.tsx`)
  - [ ] Display user information
  - [ ] Avatar upload functionality
  - [ ] Edit profile form (name, bio, etc.)
  - [ ] Account settings
- [ ] Create settings page (`app/(app)/settings/page.tsx`)
  - [ ] Notification preferences
  - [ ] Privacy settings
  - [ ] Account security (change password)
  - [ ] Delete account option
- [ ] Create API routes for profile updates
- [ ] Implement profile picture upload to Supabase Storage

---

## Phase 2: Campaign Manager

### 2.1 Campaign Foundation

- [ ] Create campaigns listing page (`app/(app)/campaigns/page.tsx`)
  - [ ] Display user's campaigns (owned + member of)
  - [ ] Create new campaign button
  - [ ] Campaign cards with metadata
  - [ ] Filter and search campaigns
  - [ ] Empty state for no campaigns
- [ ] Create campaign creation page (`app/(app)/campaigns/new/page.tsx`)
  - [ ] Campaign name and description form
  - [ ] Game system selection (predefined or custom)
  - [ ] World selection (optional, user's custom worlds)
  - [ ] System selection (optional, predefined systems or user's custom systems)
  - [ ] Privacy settings (public/private)
  - [ ] Form validation
- [ ] Implement campaign-world-system linking:
  - [ ] Create database relationships (campaign_world, campaign_system)
  - [ ] Fetch user's available worlds for selection
  - [ ] Fetch predefined systems + user's custom systems for selection
  - [ ] Allow campaigns without linked worlds/systems
  - [ ] Allow multiple campaigns to reference same world/system
- [ ] Create campaign detail page (`app/(app)/campaigns/[id]/page.tsx`)
  - [ ] Campaign overview dashboard
  - [ ] Quick stats (sessions, players, etc.)
  - [ ] Recent activity feed
  - [ ] Navigation to sub-features
  - [ ] Quick access to linked world (if any)
  - [ ] Quick access to linked system (if any)
- [ ] Create campaign settings page (`app/(app)/campaigns/[id]/settings/page.tsx`)
  - [ ] Edit campaign details
  - [ ] Link/unlink world
  - [ ] Link/unlink system
  - [ ] Warning system when unlinking shared content
  - [ ] Member management
  - [ ] Delete campaign
  - [ ] Archive campaign option
- [ ] Implement campaign-world-system integration features:
  - [ ] Search and reference world entries from campaign notes
  - [ ] Search and reference system entries from campaign notes
  - [ ] Deep linking to specific world/system pages
  - [ ] Quick navigation between campaign and linked content
- [ ] Set up access permissions for linked content:
  - [ ] Campaign players get read access to linked world
  - [ ] Campaign players get read access to linked system
  - [ ] Respect world/system ownership rules
  - [ ] Update RLS policies for shared access
- [ ] Implement campaign CRUD operations:
  - [ ] Create campaign server action
  - [ ] Update campaign server action
  - [ ] Delete campaign server action
  - [ ] Archive/restore campaign server action
- [ ] Set up React Query hooks for campaigns
- [ ] Add loading and error states

### 2.2 Player & Character Management

- [ ] Create players roster page (`app/(app)/campaigns/[id]/players/page.tsx`)
  - [ ] List all campaign members
  - [ ] Display roles (GM, Player)
  - [ ] Invite new players button
  - [ ] Remove player functionality (GM only)
- [ ] Create invite player modal/page
  - [ ] Email invitation form
  - [ ] Role selection (GM, Player)
  - [ ] Send invitation
  - [ ] Pending invitations list
- [ ] Create invitation acceptance flow
  - [ ] Email notification with invite link
  - [ ] Accept/decline invitation page
  - [ ] Auto-add to campaign on acceptance
- [ ] Create characters list page (`app/(app)/campaigns/[id]/characters/page.tsx`)
  - [ ] Display all player characters
  - [ ] Character cards with basic info
  - [ ] Add new character button
  - [ ] Filter by player
- [ ] Create character creation page (`app/(app)/campaigns/[id]/characters/new/page.tsx`)
  - [ ] Character name and description
  - [ ] Character image upload
  - [ ] Custom fields (flexible based on system)
  - [ ] Player assignment
- [ ] Create character detail page (`app/(app)/campaigns/[id]/characters/[characterId]/page.tsx`)
  - [ ] Character profile display
  - [ ] Edit character information
  - [ ] Character relationships
  - [ ] Character history/notes
- [ ] Implement character CRUD operations
- [ ] Set up permission checks (player can only edit own characters)

### 2.3 Session Management

- [ ] Create sessions list page (`app/(app)/campaigns/[id]/sessions/page.tsx`)
  - [ ] Calendar view of sessions
  - [ ] List view with past and upcoming sessions
  - [ ] Create new session button
  - [ ] Session status indicators (scheduled, completed, cancelled)
- [ ] Create session creation page (`app/(app)/campaigns/[id]/sessions/new/page.tsx`)
  - [ ] Session title and description
  - [ ] Date and time picker
  - [ ] Duration field
  - [ ] Location/platform (in-person, online link)
  - [ ] Recurring session option (optional)
- [ ] Create session detail page (`app/(app)/campaigns/[id]/sessions/[sessionId]/page.tsx`)
  - [ ] Session information display
  - [ ] Attendance tracking (who attended)
  - [ ] Session summary/recap editor
  - [ ] Session notes (linked to main notes system)
  - [ ] Mark session as complete
- [ ] Implement session CRUD operations
- [ ] Create attendance tracking system
  - [ ] Mark players as present/absent
  - [ ] Attendance statistics
- [ ] Set up session reminders:
  - [ ] Database trigger for upcoming sessions
  - [ ] Email notifications (24h before, 1h before)
  - [ ] In-app notifications
- [ ] Create session archive/history view

### 2.4 Notes & Journal System

- [ ] Create notes list page (`app/(app)/campaigns/[id]/notes/page.tsx`)
  - [ ] Hierarchical notes structure
  - [ ] Folders/categories for organization
  - [ ] Search and filter notes
  - [ ] Create new note button
  - [ ] Visibility indicators (private, shared, GM-only)
- [ ] Create note editor page (`app/(app)/campaigns/[id]/notes/[noteId]/page.tsx`)
  - [ ] Rich text editor (basic for now, Tiptap in Phase 5)
  - [ ] Note title and content
  - [ ] Visibility settings (private, shared with players, GM-only)
  - [ ] Tag system
  - [ ] Link to sessions, characters, locations
  - [ ] Autosave functionality
- [ ] Implement note CRUD operations
- [ ] Set up note visibility permissions (RLS policies)
- [ ] Create note templates:
  - [ ] Session recap template
  - [ ] NPC notes template
  - [ ] Location notes template
  - [ ] Quest notes template
- [ ] Add note linking and backlinking
- [ ] Implement note search with filters

### 2.5 Storyline & Quest Tracking

- [ ] Create storylines page (`app/(app)/campaigns/[id]/storylines/page.tsx`)
  - [ ] Visual story arc display
  - [ ] Active and completed storylines
  - [ ] Create new storyline button
- [ ] Create storyline detail page
  - [ ] Storyline overview
  - [ ] Plot threads and milestones
  - [ ] Related quests and characters
  - [ ] Timeline view
- [ ] Create quests page (`app/(app)/campaigns/[id]/quests/page.tsx`)
  - [ ] Quest list (active, completed, failed)
  - [ ] Quest status tracking
  - [ ] Create new quest button
- [ ] Create quest detail page
  - [ ] Quest description and objectives
  - [ ] Quest giver and rewards
  - [ ] Related characters and locations
  - [ ] Mark objectives as complete
  - [ ] Quest log/history
- [ ] Implement storyline and quest CRUD operations
- [ ] Create relationship system between storylines, quests, and other entities

---

## Phase 3: World Building

### 3.1 World Creation Foundation

- [ ] Create worlds listing page (`app/(app)/worlds/page.tsx`)
  - [ ] Display user's worlds (owned + shared)
  - [ ] Create new world button
  - [ ] World cards with preview
  - [ ] Filter and search worlds
  - [ ] Empty state
  - [ ] Note: No predefined worlds available (users create custom worlds only)
- [ ] Create world creation page (`app/(app)/worlds/new/page.tsx`)
  - [ ] World name and description
  - [ ] Cover image upload
  - [ ] Privacy settings
  - [ ] Initial category setup
- [ ] Create world dashboard (`app/(app)/worlds/[id]/page.tsx`)
  - [ ] World overview
  - [ ] Quick access to categories
  - [ ] Recent pages
  - [ ] World statistics
- [ ] Implement world CRUD operations
- [ ] Set up world sharing and collaboration:
  - [ ] Invite collaborators
  - [ ] Role-based access (owner, editor, viewer)
  - [ ] Manage world members
- [ ] Create world settings page
  - [ ] Edit world details
  - [ ] Member management
  - [ ] View campaigns using this world
  - [ ] Delete world
  - [ ] Export world data

### 3.2 Category System

- [ ] Create categories management page (`app/(app)/worlds/[id]/categories/page.tsx`)
  - [ ] List all categories (predefined + custom)
  - [ ] Create custom category
  - [ ] Edit category (name, icon, template)
  - [ ] Delete custom category
  - [ ] Reorder categories
- [ ] Implement predefined categories:
  - [ ] Lore
  - [ ] NPCs (Non-Player Characters)
  - [ ] Locations
  - [ ] Factions/Organizations
  - [ ] Items/Artifacts
  - [ ] Events/Timeline
  - [ ] Creatures/Monsters
  - [ ] Religions/Beliefs
  - [ ] Languages
  - [ ] Geography
  - [ ] History
- [ ] Create category icon selector
- [ ] Create category template system:
  - [ ] Default field templates per category
  - [ ] Custom field templates
  - [ ] Template inheritance
- [ ] Implement category CRUD operations

### 3.3 Notion-Style Page System

- [ ] Create pages sidebar navigation component
  - [ ] Hierarchical page tree
  - [ ] Expand/collapse nested pages
  - [ ] Quick navigation
  - [ ] Page icons
- [ ] Implement drag-and-drop page organization:
  - [ ] Install `@dnd-kit/core` and `@dnd-kit/sortable`
  - [ ] Drag to reorder pages
  - [ ] Drag to nest pages
  - [ ] Visual feedback during drag
  - [ ] Update page hierarchy in database
- [ ] Create page detail view (`app/(app)/worlds/[id]/pages/[pageId]/page.tsx`)
  - [ ] Page title editor
  - [ ] Page icon selector
  - [ ] Breadcrumb navigation
  - [ ] Page content editor (basic for now)
  - [ ] Sub-pages list
- [ ] Create page creation flow
  - [ ] Create page button (in category or as sub-page)
  - [ ] Quick page creation modal
  - [ ] Template selection
  - [ ] Auto-populate based on category template
- [ ] Implement page CRUD operations:
  - [ ] Create page (with parent relationship)
  - [ ] Update page (title, icon, content, hierarchy)
  - [ ] Delete page (with confirmation)
  - [ ] Move page (change parent)
- [ ] Set up page permissions (inherit from world)

### 3.4 Flexible Entry System & Custom Fields

- [ ] Create custom field management interface
  - [ ] Add field to page
  - [ ] Field type selector (text, number, date, select, multi-select, relation, etc.)
  - [ ] Field configuration options
  - [ ] Reorder fields
  - [ ] Delete field
- [ ] Implement field types:
  - [ ] Text (single line)
  - [ ] Textarea (multi-line)
  - [ ] Rich Text (markdown)
  - [ ] Number
  - [ ] Date
  - [ ] Select (dropdown)
  - [ ] Multi-select
  - [ ] Checkbox
  - [ ] URL
  - [ ] Email
  - [ ] Relation (link to other pages)
  - [ ] File/Image upload
- [ ] Create field rendering components for each type
- [ ] Create field editor components for each type
- [ ] Implement field value storage system
  - [ ] Save field values to database
  - [ ] Load field values on page load
  - [ ] Validate field values
- [ ] Create entry templates:
  - [ ] NPC template (name, race, class, description, etc.)
  - [ ] Location template (name, type, description, map, etc.)
  - [ ] Faction template (name, goals, members, etc.)
  - [ ] Item template (name, type, rarity, properties, etc.)
- [ ] Allow users to save custom templates

### 3.5 Rich Text Editor Integration (Tiptap)

- [ ] Install Tiptap dependencies:
  - [ ] `@tiptap/react`
  - [ ] `@tiptap/starter-kit`
  - [ ] Additional extensions as needed
- [ ] Create `<RichTextEditor>` component
  - [ ] Toolbar with formatting options
  - [ ] Bold, italic, underline, strikethrough
  - [ ] Headers (H1, H2, H3)
  - [ ] Lists (bullet, numbered)
  - [ ] Links
  - [ ] Blockquotes
  - [ ] Code blocks
  - [ ] Images
  - [ ] Tables (optional)
- [ ] Implement collaborative editing (Supabase Realtime):
  - [ ] Real-time cursor positions
  - [ ] Live text updates
  - [ ] Conflict resolution
- [ ] Add page mentions (@page linking)
- [ ] Add character mentions
- [ ] Implement autosave functionality
- [ ] Add version history support

### 3.6 Organization & Discovery

- [ ] Create global search page (`app/(app)/worlds/[id]/search/page.tsx`)
  - [ ] Full-text search across all pages
  - [ ] Filter by category
  - [ ] Filter by tags
  - [ ] Recent searches
  - [ ] Search suggestions
- [ ] Implement tagging system:
  - [ ] Add tags to pages
  - [ ] Tag autocomplete
  - [ ] Tag management
  - [ ] Filter by tags
- [ ] Create relationship mapping view:
  - [ ] Visual graph of page connections
  - [ ] Interactive node exploration
  - [ ] Relationship types (related to, created by, located in, etc.)
- [ ] Implement cross-linking:
  - [ ] Link to other pages in content
  - [ ] Backlinks display (pages that link here)
  - [ ] Broken link detection
- [ ] Create "Recently Viewed" pages list
- [ ] Create "Favorites" system:
  - [ ] Star/favorite pages
  - [ ] Quick access to favorites

### 3.7 Version History

- [ ] Implement version tracking system:
  - [ ] Save page versions on edit
  - [ ] Store diff/changes
  - [ ] Version metadata (author, timestamp)
- [ ] Create version history view:
  - [ ] List all versions of a page
  - [ ] View specific version
  - [ ] Compare versions (diff view)
  - [ ] Restore previous version
- [ ] Set up automatic version pruning (keep last N versions)

---

## Phase 4: System Building

### 4.1 System Creation Foundation

- [ ] Create systems listing page (`app/(app)/systems/page.tsx`)
  - [ ] Display user's systems (owned + shared)
  - [ ] Display available predefined systems (D&D 5e, Pathfinder 2e, etc.)
  - [ ] Separate sections for "My Systems" and "Official Systems"
  - [ ] Create new system button
  - [ ] Clone/copy predefined system button
  - [ ] System cards with preview
  - [ ] Filter and search systems
  - [ ] Empty state
- [ ] Implement predefined systems:
  - [ ] Seed database with predefined systems (D&D 5e, Pathfinder 2e, etc.)
  - [ ] Create predefined system content (categories, pages, templates)
  - [ ] Set predefined systems as read-only
  - [ ] Allow users to clone predefined systems to create custom variants
  - [ ] Regular update mechanism for predefined system content
  - [ ] Version tracking for predefined systems
- [ ] Create system creation page (`app/(app)/systems/new/page.tsx`)
  - [ ] System name and description
  - [ ] Option to start from scratch or clone predefined system
  - [ ] Cover image upload
  - [ ] Privacy settings
  - [ ] Initial category setup
- [ ] Create predefined system detail page (read-only view)
  - [ ] System overview and description
  - [ ] Browse predefined system content
  - [ ] Clone system button
  - [ ] Link to official documentation/sources (if applicable)
- [ ] Create system dashboard (`app/(app)/systems/[id]/page.tsx`)
  - [ ] System overview
  - [ ] Quick access to categories
  - [ ] Recent pages
  - [ ] System statistics
- [ ] Implement system CRUD operations
- [ ] Set up system sharing and collaboration (same as worlds)
- [ ] Create system settings page
  - [ ] Edit system details
  - [ ] Member management
  - [ ] View campaigns using this system
  - [ ] Delete system
  - [ ] Export system data

### 4.2 System-Specific Categories

- [ ] Create categories management page (same structure as worlds)
- [ ] Implement predefined categories:
  - [ ] Rules & Core Mechanics
  - [ ] Character Creation
  - [ ] Classes/Archetypes
  - [ ] Races/Species
  - [ ] Skills & Abilities
  - [ ] Combat System
  - [ ] Magic System
  - [ ] Equipment & Items
  - [ ] Conditions & Status Effects
  - [ ] Advancement/Leveling
  - [ ] Crafting System
  - [ ] Economy & Trade
- [ ] Implement category CRUD operations (reuse from worlds)

### 4.3 Notion-Style Page System (System Builder)

- [ ] Reuse page system from World Building (same component architecture)
- [ ] Create system-specific page templates:
  - [ ] Class template (name, description, abilities, progression, etc.)
  - [ ] Race template (name, traits, bonuses, etc.)
  - [ ] Spell/Ability template (name, level, effect, cost, etc.)
  - [ ] Item template (name, stats, rarity, cost, etc.)
  - [ ] Rule template (title, description, examples, etc.)
- [ ] Implement drag-and-drop page organization
- [ ] Set up page permissions (inherit from system)

### 4.4 System-Specific Custom Fields

- [ ] Implement system-specific field types:
  - [ ] Dice notation field (e.g., "2d6+3")
  - [ ] Formula field (e.g., "(STR + DEX) / 2")
  - [ ] Stat block field (structured stats)
  - [ ] Ability score field
- [ ] Create dice notation parser and validator
- [ ] Create formula calculator
- [ ] Implement field types (reuse from worlds where applicable)
- [ ] Create system entry templates

### 4.5 Rich Text Editor for Systems

- [ ] Reuse Tiptap editor from World Building
- [ ] Add system-specific extensions:
  - [ ] Dice roll syntax highlighting
  - [ ] Formula syntax highlighting
  - [ ] Stat block formatting
  - [ ] Table of contents for rule pages
- [ ] Implement collaborative editing (same as worlds)

### 4.6 Organization & Discovery (Systems)

- [ ] Implement global search (reuse from worlds)
- [ ] Implement tagging system (reuse from worlds)
- [ ] Create relationship mapping for systems:
  - [ ] Class-to-ability connections
  - [ ] Item-to-rule connections
  - [ ] Spell-to-class connections
- [ ] Implement cross-linking and backlinks
- [ ] Create favorites and recently viewed

### 4.7 System Publishing & Templates

- [ ] Create system publishing feature:
  - [ ] Publish system as template
  - [ ] Public system gallery
  - [ ] Visibility settings (public, unlisted, private)
- [ ] Create system templates library page:
  - [ ] Browse published systems
  - [ ] Filter by tags/categories
  - [ ] Preview system
  - [ ] Clone/import system template
- [ ] Implement system import/export:
  - [ ] Export system to JSON
  - [ ] Import system from JSON
  - [ ] Validation and error handling

---

## Phase 5: Additional Features & Polish

### 5.1 Global Search

- [ ] Create global search page (`app/(app)/search/page.tsx`)
  - [ ] Search across campaigns, worlds, and systems
  - [ ] Filter by content type
  - [ ] Advanced search options
  - [ ] Search history
- [ ] Implement full-text search:
  - [ ] Set up PostgreSQL full-text search
  - [ ] Create search indexes
  - [ ] Optimize search queries
- [ ] Add search keyboard shortcut (Cmd/Ctrl + K)
- [ ] Implement search result highlighting

### 5.2 Notification System

- [ ] Create notifications data model
- [ ] Implement notification types:
  - [ ] Session reminders
  - [ ] Campaign invites
  - [ ] World/system share invites
  - [ ] Mentions in notes/pages
  - [ ] Comments on pages (if implemented)
  - [ ] System updates
- [ ] Create notification center UI:
  - [ ] Dropdown notification list in header
  - [ ] Mark as read/unread
  - [ ] Clear all notifications
  - [ ] Notification preferences link
- [ ] Implement email notifications:
  - [ ] Set up email service (Supabase email or transactional service)
  - [ ] Create email templates
  - [ ] Notification digest options (immediate, daily, weekly)
- [ ] Create notification preferences page:
  - [ ] Toggle notifications by type
  - [ ] Email vs. in-app preferences
  - [ ] Notification frequency settings
- [ ] Set up real-time notifications (Supabase Realtime)

### 5.3 Data Export

- [ ] Implement campaign export:
  - [ ] Export to JSON
  - [ ] Export to Markdown (session logs, notes)
  - [ ] Export to PDF (formatted campaign summary)
  - [ ] Selective export (choose what to include)
- [ ] Implement world export:
  - [ ] Export to JSON
  - [ ] Export to Markdown (all pages)
  - [ ] Include images and assets
- [ ] Implement system export:
  - [ ] Export to JSON
  - [ ] Export to Markdown
  - [ ] Export as template
- [ ] Create backup functionality:
  - [ ] Manual backup trigger
  - [ ] Scheduled backups (optional)
  - [ ] Backup download and restore

### 5.4 Data Import (Post-MVP)

- [ ] Create import wizard UI
- [ ] Implement campaign import:
  - [ ] Import from JSON
  - [ ] Import from other TTRPG tools (Roll20, Foundry, etc.)
  - [ ] Field mapping interface
  - [ ] Validation and error handling
- [ ] Implement world/system import:
  - [ ] Import from JSON
  - [ ] Import from Markdown (with frontmatter)
  - [ ] Bulk import functionality
- [ ] Implement backup restore:
  - [ ] Upload backup file
  - [ ] Restore specific campaigns/worlds/systems
  - [ ] Conflict resolution

### 5.5 Mobile Responsiveness

- [ ] Audit all pages for mobile compatibility
- [ ] Optimize layouts for small screens:
  - [ ] Collapsible sidebars
  - [ ] Mobile navigation menu (hamburger)
  - [ ] Touch-optimized buttons and inputs
  - [ ] Responsive tables (scrollable or stacked)
- [ ] Optimize forms for mobile:
  - [ ] Larger touch targets
  - [ ] Mobile-friendly date/time pickers
  - [ ] On-screen keyboard considerations
- [ ] Test on various devices and screen sizes:
  - [ ] iPhone (Safari)
  - [ ] Android (Chrome)
  - [ ] iPad/tablets
- [ ] Implement Progressive Web App (PWA) features:
  - [ ] Service worker for offline support
  - [ ] Web app manifest
  - [ ] Add to home screen prompt
  - [ ] Push notifications (optional)

### 5.6 Dice Roller (Post-MVP)

- [ ] Create dice roller component:
  - [ ] Dice notation input (e.g., "2d20+5")
  - [ ] Roll button
  - [ ] Result display with breakdown
  - [ ] Roll history
- [ ] Implement dice rolling logic:
  - [ ] Parse dice notation
  - [ ] Generate random rolls
  - [ ] Calculate modifiers
  - [ ] Support advantage/disadvantage
  - [ ] Support custom dice (d3, d100, etc.)
- [ ] Integrate dice roller in campaigns:
  - [ ] Quick roll from session pages
  - [ ] Roll from character sheets
  - [ ] Share rolls with other players
- [ ] Add dice roller to system builder:
  - [ ] Test formulas and rolls
  - [ ] Include in ability/spell descriptions

### 5.7 Community Features (Post-MVP)

- [ ] Create public gallery page (`app/gallery/page.tsx`)
  - [ ] Browse public campaigns/worlds/systems
  - [ ] Filter by category and tags
  - [ ] Search public content
  - [ ] Featured content section
- [ ] Implement commenting system:
  - [ ] Add comments to public pages
  - [ ] Reply to comments
  - [ ] Moderation tools
- [ ] Implement rating/review system:
  - [ ] Rate public content (1-5 stars)
  - [ ] Write reviews
  - [ ] Sort by rating
- [ ] Create user profiles (public view):
  - [ ] Display user's public content
  - [ ] Follow/unfollow users
  - [ ] Activity feed
- [ ] Implement content reporting:
  - [ ] Report inappropriate content
  - [ ] Admin moderation queue

### 5.8 Templates & Marketplace (Post-MVP)

- [ ] Create templates library page (`app/templates/page.tsx`)
  - [ ] Browse campaign/world/system templates
  - [ ] Filter by type, category, tags
  - [ ] Preview templates
  - [ ] Clone/use template
- [ ] Implement template creation:
  - [ ] Save campaign/world/system as template
  - [ ] Template metadata (name, description, tags, preview image)
  - [ ] Public or private template
- [ ] Create community templates section:
  - [ ] Submit template for community
  - [ ] Template approval process (moderation)
  - [ ] Featured community templates
- [ ] (Optional) Implement marketplace:
  - [ ] Paid template support
  - [ ] Payment integration (Stripe)
  - [ ] Revenue sharing for creators

### 5.9 Calendar & Timeline (Post-MVP)

- [ ] Create in-world calendar system:
  - [ ] Custom calendar configuration (months, days, seasons)
  - [ ] Current date tracking
  - [ ] Display calendar on world pages
- [ ] Create timeline view for worlds:
  - [ ] Visual timeline of events
  - [ ] Add events to timeline
  - [ ] Era/age markers
  - [ ] Zoom in/out on timeline
- [ ] Create campaign calendar:
  - [ ] In-game calendar integration
  - [ ] Track in-game time progression
  - [ ] Link sessions to in-game dates
- [ ] Create historical event tracking:
  - [ ] Add historical events to timeline
  - [ ] Link events to locations, factions, characters
  - [ ] Display events on world pages

---

## Phase 6: Ancillary Pages & Marketing

### 6.1 Public Marketing Pages

- [ ] Create homepage (`app/page.tsx`)
  - [ ] Hero section with CTA
  - [ ] Feature highlights
  - [ ] Screenshots/demos
  - [ ] Testimonials (when available)
  - [ ] Footer with links
- [ ] Create features page (`app/features/page.tsx`)
  - [ ] Detailed feature showcase
  - [ ] Benefits and use cases
  - [ ] Comparison with other tools (optional)
- [ ] Create pricing page (`app/pricing/page.tsx`) (if applicable)
  - [ ] Pricing tiers (free, pro, etc.)
  - [ ] Feature comparison table
  - [ ] FAQ section
  - [ ] Sign-up CTAs
- [ ] Create public roadmap page (`app/roadmap/page.tsx`)
  - [ ] Display upcoming features
  - [ ] Completed features
  - [ ] User voting/feedback (optional)
- [ ] Create about page (`app/about/page.tsx`)
  - [ ] Project mission and vision
  - [ ] Team information
  - [ ] Contact information
- [ ] Create blog (optional) (`app/blog/page.tsx`)
  - [ ] CMS integration or static posts
  - [ ] Blog post listing
  - [ ] Individual post pages
  - [ ] RSS feed

### 6.2 Legal & Documentation Pages

- [ ] Create Terms of Service page (`app/legal/terms/page.tsx`)
  - [ ] User agreement and terms
  - [ ] Acceptable use policy
- [ ] Create Privacy Policy page (`app/legal/privacy/page.tsx`)
  - [ ] Data collection and usage
  - [ ] Cookie policy
  - [ ] User rights (GDPR, CCPA compliance)
- [ ] Create Cookie Policy page (`app/legal/cookies/page.tsx`)
  - [ ] Cookie usage explanation
  - [ ] Cookie consent banner
- [ ] Create documentation/help center (`app/docs/page.tsx`)
  - [ ] Getting started guide
  - [ ] Feature tutorials
  - [ ] FAQ
  - [ ] Troubleshooting
  - [ ] Searchable documentation
- [ ] Create contact/support page (`app/contact/page.tsx`)
  - [ ] Contact form
  - [ ] Support email
  - [ ] Social media links
  - [ ] Response time expectations

---

## Phase 7: Testing, Optimization & Launch

### 7.1 Testing

- [ ] Set up testing environment:
  - [ ] Install testing dependencies (@testing-library/react, vitest/jest)
  - [ ] Configure test runner
  - [ ] Set up test database (separate from dev)
- [ ] Write unit tests:
  - [ ] Test utility functions
  - [ ] Test validation schemas
  - [ ] Test permission helpers
  - [ ] Test data transformations
- [ ] Write integration tests:
  - [ ] Test auth flows
  - [ ] Test CRUD operations
  - [ ] Test RLS policies
  - [ ] Test API routes
- [ ] Write component tests:
  - [ ] Test form components
  - [ ] Test UI components
  - [ ] Test user interactions
- [ ] Write end-to-end tests (optional):
  - [ ] Set up Playwright or Cypress
  - [ ] Test critical user flows
  - [ ] Test authentication
  - [ ] Test campaign/world/system creation
- [ ] Manual testing:
  - [ ] Test on multiple browsers
  - [ ] Test on mobile devices
  - [ ] Test edge cases
  - [ ] User acceptance testing (UAT)
- [ ] Security testing:
  - [ ] Test RLS policies with different user scenarios
  - [ ] Test input sanitization
  - [ ] Test file upload security
  - [ ] Penetration testing (optional)

### 7.2 Performance Optimization

- [ ] Optimize database queries:
  - [ ] Add missing indexes
  - [ ] Optimize slow queries
  - [ ] Implement pagination
  - [ ] Use database views for complex queries
- [ ] Optimize React components:
  - [ ] Implement code splitting
  - [ ] Use React.memo for expensive components
  - [ ] Optimize re-renders
  - [ ] Lazy load heavy components
- [ ] Optimize images and assets:
  - [ ] Use Next.js Image component
  - [ ] Implement image optimization
  - [ ] Lazy load images
  - [ ] Use WebP format
- [ ] Implement caching:
  - [ ] React Query caching strategies
  - [ ] CDN caching for static assets
  - [ ] Database query caching (if needed)
- [ ] Optimize bundle size:
  - [ ] Analyze bundle with webpack-bundle-analyzer
  - [ ] Remove unused dependencies
  - [ ] Use tree-shaking
  - [ ] Split large dependencies
- [ ] Implement loading states and skeleton screens:
  - [ ] Add loading spinners
  - [ ] Create skeleton screens for major pages
  - [ ] Implement optimistic updates

### 7.3 SEO & Accessibility

- [ ] Implement SEO best practices:
  - [ ] Add metadata to all pages
  - [ ] Create sitemap.xml
  - [ ] Add robots.txt
  - [ ] Implement Open Graph tags
  - [ ] Add Twitter Card tags
  - [ ] Implement structured data (JSON-LD)
- [ ] Accessibility audit:
  - [ ] Test with screen readers
  - [ ] Ensure keyboard navigation works
  - [ ] Check color contrast ratios
  - [ ] Add ARIA labels where needed
  - [ ] Test with accessibility tools (Lighthouse, axe DevTools)
- [ ] Semantic HTML:
  - [ ] Use proper heading hierarchy
  - [ ] Use semantic HTML elements
  - [ ] Add alt text to images

### 7.4 Documentation & User Onboarding

- [ ] Create user documentation:
  - [ ] Write getting started guide
  - [ ] Create feature tutorials with screenshots
  - [ ] Write FAQ
  - [ ] Create video tutorials (optional)
- [ ] Implement user onboarding:
  - [ ] First-time user welcome flow
  - [ ] Interactive product tour
  - [ ] Tooltips for key features
  - [ ] Empty state guidance
- [ ] Create developer documentation (if open source):
  - [ ] Setup instructions
  - [ ] Architecture overview
  - [ ] Contributing guidelines
  - [ ] API documentation

### 7.5 Error Tracking & Monitoring

- [ ] Set up error tracking:
  - [ ] Integrate Sentry or similar service
  - [ ] Configure error reporting
  - [ ] Set up error notifications
- [ ] Set up application monitoring:
  - [ ] Monitor application performance
  - [ ] Track user analytics (privacy-respecting)
  - [ ] Monitor database performance
  - [ ] Set up uptime monitoring
- [ ] Create admin dashboard:
  - [ ] View system health
  - [ ] Monitor active users
  - [ ] View error logs
  - [ ] Moderate content (if community features)

### 7.6 Deployment

- [ ] Set up production environment:
  - [ ] Create production Supabase project
  - [ ] Configure environment variables
  - [ ] Set up domain and DNS
  - [ ] Configure SSL certificate
- [ ] Choose hosting platform (Vercel recommended for Next.js):
  - [ ] Set up Vercel project
  - [ ] Connect GitHub repository
  - [ ] Configure build settings
  - [ ] Set up preview deployments
- [ ] Set up CI/CD pipeline:
  - [ ] Automated testing on push
  - [ ] Automated deployments
  - [ ] Staging environment
- [ ] Database migration strategy:
  - [ ] Set up migration system (Supabase migrations)
  - [ ] Test migrations on staging
  - [ ] Plan production migration
- [ ] Pre-launch checklist:
  - [ ] Test all critical features in production
  - [ ] Verify email sending works
  - [ ] Test payment processing (if applicable)
  - [ ] Verify analytics tracking
  - [ ] Test error reporting
  - [ ] Check performance metrics

### 7.7 Launch

- [ ] Soft launch (beta):
  - [ ] Invite small group of beta testers
  - [ ] Gather feedback
  - [ ] Fix critical bugs
  - [ ] Iterate on user experience
- [ ] Public launch:
  - [ ] Announce on social media
  - [ ] Post on relevant communities (Reddit, Discord, etc.)
  - [ ] Reach out to TTRPG influencers
  - [ ] Write launch blog post
  - [ ] Send email to beta users
- [ ] Post-launch monitoring:
  - [ ] Monitor error rates
  - [ ] Track user signups and activity
  - [ ] Respond to user feedback
  - [ ] Fix critical bugs immediately
  - [ ] Plan first post-launch updates

---

## Ongoing Maintenance

### Post-Launch Tasks

- [ ] Monitor user feedback and bug reports
- [ ] Regular security updates for dependencies
- [ ] Database backup verification
- [ ] Performance monitoring and optimization
- [ ] Content moderation (if community features)
- [ ] User support and customer service
- [ ] Regular feature updates based on user requests
- [ ] Maintain documentation and tutorials
- [ ] Track and prioritize feature requests
- [ ] Plan future phases and major updates

---

## Notes

### Prioritization Strategy

- **Phase 1 is critical** - Complete foundation before moving to feature development
- **Authentication first** - Users need to sign up before accessing any features
- **Start simple** - Basic functionality before advanced features (e.g., simple text editor before Tiptap)
- **Reuse components** - World Building and System Building share many components
- **Test early** - Don't wait until Phase 7 to start testing
- **Iterate quickly** - Build, test, gather feedback, refine

### Technical Debt Considerations

- Document decisions and trade-offs
- Refactor as needed, but don't over-engineer early
- Keep code DRY (Don't Repeat Yourself) where it makes sense
- Write tests for critical functionality
- Use TypeScript strictly to catch errors early

### Success Metrics to Track

- User signups and retention
- Campaign/world/system creation rates
- Feature adoption rates
- User engagement (sessions per user, time spent)
- Error rates and bug reports
- Performance metrics (page load times, API response times)
- User feedback and satisfaction scores
