# Copilot Instructions for Aether Keep v2

## Project Overview

Aether Keep v2 is a TTRPG management platform with three core modules: **Campaign Manager**, **World Building**, and **System Building**. The project is in early development (v0.1.0) with foundational Next.js setup complete but core features not yet implemented.

## Architecture & Stack

### Framework & Language

- **Next.js 16** with App Router (`app/` directory structure)
- **TypeScript** with strict mode enabled
- **React 19.2** (latest canary with improved type safety)
- Path aliases use `@/*` for root-level imports (see `tsconfig.json`)

### Styling

- **Tailwind CSS v4** (postcss plugin-based, NO config file)
- Custom theme tokens defined inline in `app/globals.css` using `@theme inline`
- Geist Sans & Geist Mono fonts loaded via `next/font/google` in layout
- Dark mode via `prefers-color-scheme` with CSS variables (`--background`, `--foreground`)

### Planned Stack (not yet implemented)

- **Supabase**: Auth, PostgreSQL database, storage, and real-time features
- **Tiptap**: Notion-like rich text editor for flexible content pages
- **@dnd-kit**: Drag-and-drop for hierarchical page organization
- **React Hook Form + Zod**: Form validation
- **TanStack Query**: Server state and caching

## Key Development Patterns

### File Structure Convention

```
app/
  (auth)/          # Route groups for authenticated pages
  (marketing)/     # Route groups for public marketing pages
  layout.tsx       # Root layout with fonts and metadata
  page.tsx         # Homepage
development/       # Documentation and planning (NOT code)
  roadmap.md       # Complete feature specs and tech stack
  design.md        # UI/UX layouts and design principles
  plan.md          # Empty, development plan TBD
  database.md      # Empty, schema design TBD
```

### Styling Patterns

- Use Tailwind v4's inline theme tokens in `globals.css` for design system
- CSS variables (`--background`, `--foreground`) bridge CSS and Tailwind
- No `tailwind.config.js` - configuration via PostCSS plugin
- Dark mode implementation: modify CSS variables in `@media (prefers-color-scheme: dark)`

### TypeScript Configuration

- Import paths: Use `@/` prefix for root imports (e.g., `@/app/components`)
- Target ES2017 for broader compatibility
- `react-jsx` transform (no React import needed)
- Strict type checking enabled

## Critical Workflows

### Development Server

```bash
npm run dev  # Starts Next.js dev server on localhost:3000
```

### Linting

- ESLint configured with Next.js presets (`eslint-config-next`)
- Uses ESLint flat config format (`eslint.config.mjs`)
- Run: `npm run lint`

### Build & Production

```bash
npm run build  # Production build
npm start      # Run production server
```

## Feature Implementation Guidelines

### Notion-Style Page System (World Building & System Building)

Both modules share the same architectural pattern:

- **Hierarchical pages**: Drag-and-drop nested page organization
- **Flexible content**: Rich text editing with custom fields per entry
- **Category-based**: Predefined + custom categories with templates
- **Cross-linking**: Backlinks, references, relationship mapping
- See `development/roadmap.md` for complete feature specs

### Campaign Manager vs. World/System Modules

- **Campaign Manager**: Session-based, time-oriented (scheduling, attendance, sessions)
- **World/System Building**: Content-oriented, hierarchical knowledge bases
- All three modules integrate but are architecturally distinct

### Authentication & Permissions

- Supabase Auth with Row Level Security (RLS) policies
- Owner/editor/viewer roles per resource (campaigns, worlds, systems)
- See `development/roadmap.md` Security & Permissions section

## Documentation Sources

All planning docs are in `development/`:

- **`roadmap.md`**: Single source of truth for features, tech stack, and dependencies
- **`design.md`**: UI layouts and design principles (sidebar + main content area)
- **`plan.md`**: Comprehensive action item list organized by development phase
- **`database.md`**: Reserved for schema design
- **`changelog.md`**: Development changelog tracking all changes

When implementing features, always cross-reference `development/roadmap.md` for:

- Exact dependency packages needed
- Feature scope and requirements
- Security considerations

## Current State

⚠️ **Early Development**: Only Next.js scaffold exists. No Supabase, no auth, no database, no core features implemented yet. When adding features, install dependencies from the planned stack list in `roadmap.md`.

## Common Tasks

### Adding a New Route

1. Create route group if needed: `app/(auth)/dashboard/page.tsx`
2. Use TypeScript for all components
3. Follow Next.js App Router conventions (server components by default)

### Adding Styling

1. Define design tokens in `app/globals.css` `@theme inline` block
2. Use Tailwind utility classes in components
3. Reference CSS variables for dynamic theming

### Before Installing Packages

Check `development/roadmap.md` "Key Dependencies" section for planned packages to ensure consistency with architecture decisions.

---

## Development Workflow

### Following the Development Plan

**CRITICAL**: Always follow the phased development plan in `development/plan.md`:

1. **Check the plan** before starting any new feature implementation
2. **Follow phase order**: Complete Phase 1 (Foundation) tasks before moving to Phase 2, etc.
3. **Mark tasks as complete**: When you complete a task, mark the checkbox in `plan.md` as `[x]`
4. **Request validation**: After marking tasks complete, inform the developer to validate the work
5. **Stay organized**: Don't jump ahead to later phases without completing prerequisite tasks

### Priority Guidelines

- **Phase 1 is mandatory first** - Authentication, database, and core UI must be complete before features
- **Build incrementally** - Complete full vertical slices (e.g., entire auth flow) rather than partial implementations
- **Test as you go** - Don't wait until Phase 7 to test; validate each feature as it's built
- **Reuse components** - World Building and System Building share architecture; build reusable solutions

### Updating the Changelog

**REQUIRED**: After completing any meaningful work (features, fixes, refactors), update `development/changelog.md`:

**Format**:

```markdown
## [Date: YYYY-MM-DD HH:MM]

Brief paragraph describing what was changed, added, or fixed. Include which phase/section of the plan was worked on if applicable. Mention key files modified or features implemented.
```

**When to log**:

- ✅ Completing plan.md tasks (mark multiple related tasks)
- ✅ Installing new dependencies
- ✅ Creating new routes or major components
- ✅ Database schema changes
- ✅ Bug fixes that affect functionality
- ✅ Configuration changes
- ❌ Minor typo fixes or trivial changes
- ❌ Work in progress (only log when complete)

**Example**:

```markdown
## [Date: 2025-10-31 14:30]

Completed Phase 1.5 authentication system setup. Created sign-in, sign-up, and password reset pages with full form validation using react-hook-form and Zod. Implemented Supabase Auth integration with middleware protection for authenticated routes. Set up auth callback handler and email verification flow. Updated plan.md to mark all Phase 1.5 tasks as complete.
```

### Task Completion Protocol

1. Complete the work thoroughly
2. Mark the checkbox(es) in `plan.md` as `[x]`
3. Update `changelog.md` with a dated entry
4. Inform the developer: "Tasks marked complete in plan.md - please validate"
5. Wait for developer validation before proceeding to next tasks
