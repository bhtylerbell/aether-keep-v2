# Development Roadmap

## Project Overview

**Aether Keep v2** - A comprehensive TTRPG management platform with three core features:

1. Campaign Manager
2. World Building
3. System Building

## Core Features

### 1. Campaign Manager

- **Campaign Creation & Management**
  - Create new campaigns
  - Invite players to join campaigns
  - Role-based access (GM vs. Players)
- **Session Tools**
  - Session scheduling
  - Automated reminders
  - Attendance tracking
  - Session history and archives
- **Player & Character Management**
  - Player roster
  - Character profiles and sheets
  - Character relationships and party dynamics
- **Storyline Tracking**
  - Campaign narrative structure
  - Plot threads and story arcs
  - Quest and objective tracking
- **Notes System**
  - Personal notes (private to each player)
  - Shared notes (visible to all players)
  - GM-only notes
  - Session summaries and recaps

### 2. World Building

- **Notion-Style Page System**
  - Hierarchical page organization
  - Nested pages and sub-pages
  - Drag-and-drop page management
  - Rich text editing and formatting
- **Category Management**
  - Predefined categories (Lore, NPCs, Locations, Factions, Items, Events, etc.)
  - Custom user-created categories
  - Category icons and customization
  - Category templates
- **Flexible Entry System**
  - Predefined entry templates for common types
  - Custom field creation
  - Multiple field types (text, markdown, images, numbers, dates, relations, etc.)
  - User-defined entry structures
  - No forced data conformity
- **Organization & Discovery**
  - Search and filter across all pages
  - Tags and metadata
  - Visual relationship mapping
  - Cross-linking between entries
  - Backlinks and references
- **Collaboration**
  - Share worlds with other users
  - Collaborative editing
  - Version history

### 3. System Building

- **Notion-Style Page System**
  - Hierarchical page organization
  - Nested pages and sub-pages
  - Drag-and-drop page management
  - Rich text editing and formatting

- **Predefined Systems**
  - Official predefined systems available for selection (D&D 5e, Pathfinder 2e, etc.)
  - Read-only predefined system content
  - Users can clone/copy predefined systems to create custom variants
  - Predefined systems regularly updated and maintained
- **Category Management**
  - Predefined categories (Rules, Mechanics, Character Creation, Classes, Races, Skills, Abilities, Combat, Magic, Equipment, etc.)
  - Custom user-created categories
  - Category icons and customization
  - Category templates
- **Flexible Entry System**
  - Predefined entry templates for common types
  - Custom field creation
  - Multiple field types (text, markdown, images, numbers, dates, formulas, dice notation, etc.)
  - User-defined entry structures
  - No forced data conformity
- **Organization & Discovery**
  - Search and filter across all pages
  - Tags and metadata
  - Visual relationship mapping
  - Cross-linking between entries
  - Backlinks and references
- **Collaboration**
  - Share systems with other users
  - Collaborative editing
  - Version history
  - System publishing and templates

### 4. Cross-Module Integration

- **Campaign-World-System Linking**
  - Link existing worlds to campaigns during campaign creation
  - Link existing systems to campaigns during campaign creation
  - Select from predefined systems (D&D 5e, Pathfinder 2e, etc.) during campaign creation
  - Optional linking (campaigns can exist without worlds/systems)
  - Multiple campaigns can reference the same world or system
  - No predefined worlds available (users create their own custom worlds)
- **Access & Permissions Integration**
  - Campaign players automatically gain read access to linked worlds/systems
  - GM access levels respect world/system ownership rules
  - Shared worlds/systems available for campaign linking
- **Content Access from Campaigns**
  - Quick access to linked world/system content from campaign interface
  - Search and reference world/system entries within campaign notes
  - Deep linking to specific world/system pages from campaign content
- **Unlinking & Management**
  - Ability to link/unlink worlds and systems from campaigns
  - Change linked world/system without data loss
  - Warning system when unlinking shared content
- **Campaign Context in World/System**
  - View which campaigns are using a world/system
  - Campaign-specific notes or variants within worlds/systems (future consideration)

## Additional Features

### Core Features (MVP)

#### Search Functionality

- Global search across campaigns, worlds, and systems
- Full-text search implementation
- Advanced filtering capabilities
- Search within specific categories
- Recent searches and search history

#### Data Export

- Export campaigns to PDF/JSON/Markdown
- Export worlds and systems
- Backup functionality
- Selective export options

#### Notification System

- Session reminders and alerts
- Activity notifications (mentions, updates, invites)
- Email notifications
- In-app notification center
- Notification preferences and settings

#### Mobile Responsiveness

- Fully responsive design for all screen sizes
- Touch-optimized interfaces
- Mobile-friendly navigation
- Tablet layout optimizations
- Progressive Web App (PWA) considerations

### Nice-to-Have Features (Post-MVP)

#### Data Import

- Import from other TTRPG tools
- Bulk import functionality
- Import validation and error handling
- Restore from backups

#### Dice Roller

- Built-in dice roller for campaigns
- Custom dice formulas and notation
- Dice roll history
- Shareable roll results

#### Community Features

- Public campaigns/worlds/systems gallery
- Comments and feedback system
- Rating and review system
- Follow other creators
- Featured content showcase

#### Templates & Marketplace

- Pre-built campaign templates
- World and system templates
- Community-created content library
- Template categories and tags

#### Calendar & Timeline

- In-world calendar system
- Timeline view for campaign events
- Age/era tracking for worlds
- Event scheduling and milestones
- Historical event tracking

## Ancillary Pages

### Public Pages

- **Homepage** - Marketing landing page with hero and CTAs
- **Features** - Detailed feature showcase and benefits
- **Pricing** - Pricing tiers and subscription options (if applicable)
- **Public Roadmap** - Development progress and upcoming features for users to follow
- **About** - Company/project information and mission
- **Blog** (optional) - Updates, tutorials, and community content

### Legal & Documentation

- **Terms of Service** - User agreement and terms
- **Privacy Policy** - Data handling and privacy practices
- **Cookie Policy** - Cookie usage and consent
- **Documentation/Help Center** - User guides and tutorials
- **FAQ** - Frequently asked questions
- **Contact/Support** - Contact form and support channels

### Account Pages

- **Sign In** - User authentication
- **Sign Up/Register** - New user registration
- **Password Reset** - Forgot password flow
- **Email Verification** - Account verification

## Technology Stack

### Frontend

- **Framework:** Next.js (App Router)
- **Styling:** Tailwind CSS v4
- **Language:** TypeScript

### Backend & Services

- **Authentication:** Supabase Auth
- **Database:** Supabase (PostgreSQL)
- **File Storage:** Supabase Storage Buckets
- **Real-time Features:** Supabase Realtime

## Security & Permissions

### User Roles & Permissions

- **Site Administration**
  - Super admin role for site management
  - User management and moderation
  - System configuration and monitoring
- **Content Ownership & Access Control**
  - Owner, editor, and viewer roles
  - Granular permission levels per resource
  - Role-based access control (RBAC)
- **Sharing & Collaboration**
  - Share campaigns, worlds, and systems with specific users
  - Public/private visibility settings
  - Invitation and access management
  - Revoke access controls

### Security Measures

- **Input Sanitization**
  - Prevent SQL injection attacks
  - XSS (Cross-Site Scripting) prevention
  - Sanitize user-generated content
  - Validate all inputs server-side
- **Authentication & Authorization**
  - Supabase Auth integration
  - Row Level Security (RLS) policies
  - JWT token validation
  - Session management
  - Multi-factor authentication (MFA) support
- **Data Protection**
  - Encrypted data transmission (HTTPS)
  - Secure password storage (handled by Supabase)
  - API rate limiting
  - CSRF protection
- **File Upload Security**
  - File type validation
  - File size limits
  - Malware scanning considerations
  - Secure storage bucket policies
- **Audit & Monitoring**
  - Activity logging
  - Suspicious activity detection
  - Error tracking and reporting

## Key Dependencies

### Core Framework & Language

- **next** - React framework with App Router
- **react** & **react-dom** - UI library
- **typescript** - Type safety

### Styling & UI

- **tailwindcss** (v4) - Utility-first CSS framework
- **@headlessui/react** - Unstyled, accessible UI components
- **@heroicons/react** - Beautiful hand-crafted SVG icons
- **clsx** - Conditional className utilities
- **tailwind-merge** - Merge Tailwind classes without conflicts

### Supabase & Database

- **@supabase/supabase-js** - Supabase client
- **@supabase/auth-helpers-nextjs** - Auth helpers for Next.js
- **@supabase/ssr** - Server-side rendering support

### Forms & Validation

- **react-hook-form** - Performant form management
- **zod** - TypeScript-first schema validation
- **@hookform/resolvers** - Validation resolvers for react-hook-form

### Rich Text Editing

- **@tiptap/react** - Headless rich text editor (Notion-like)
- **@tiptap/starter-kit** - Essential Tiptap extensions
- **@tiptap/extension-\*** - Additional extensions as needed

### Data Management & State

- **@tanstack/react-query** - Server state management and caching
- **zustand** - Lightweight client state management (if needed)
- **immer** - Immutable state updates made easy

### Date & Time

- **date-fns** - Modern date utility library
- **react-day-picker** - Flexible date picker component

### Drag & Drop

- **@dnd-kit/core** - Modern drag-and-drop toolkit
- **@dnd-kit/sortable** - Sortable presets for drag-and-drop

### Security & Sanitization

- **dompurify** - XSS sanitization for HTML
- **isomorphic-dompurify** - DOMPurify for both client and server
- **validator** - String validation and sanitization

### Notifications & UI Feedback

- **sonner** or **react-hot-toast** - Toast notifications
- **nprogress** - Loading progress bar

### Development & Testing

- **eslint** - Code linting
- **prettier** - Code formatting
- **@testing-library/react** - React component testing
- **@testing-library/jest-dom** - Custom jest matchers
- **vitest** or **jest** - Testing framework

### Utilities

- **nanoid** - Unique ID generator
- **ms** - Time string parsing

## Development Phases

### Phase 1: Foundation

- Project setup and configuration
- Authentication system
- Database schema design
- Core UI components

### Phase 2: Campaign Manager

- Campaign CRUD operations
- Session management
- Character tracking
- Notes and journal system

### Phase 3: World Building

- World creation and management
- Location builder
- NPC database
- Faction system
- Lore organization

### Phase 4: System Building

- System templates
- Rules engine
- Character sheet builder
- Dice mechanics system

### Phase 5: Polish & Launch

- Testing and bug fixes
- Performance optimization
- Documentation
- Deployment

## Resources & References

- [Next.js Documentation](https://nextjs.org/docs)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)
- [Supabase Documentation](https://supabase.com/docs)

## Success Metrics

- User engagement and retention
- Feature adoption rates
- Community feedback
- Performance benchmarks
