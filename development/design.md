# Design Documentation

> **Note:** This is a working document and may be updated throughout development as design decisions evolve.

## Core Site Layout

### Unauthenticated Users (Marketing Site)

#### Homepage Layout

- **Modern, responsive design** optimized for all screen sizes
- **Hero Section**
  - Eye-catching headline and tagline
  - Brief value proposition
  - Primary CTA buttons (Sign Up, Get Started)
  - Hero image/illustration
- **Features Section**
  - Showcase three core features (Campaign Manager, World Building, System Building)
  - Visual cards or sections for each feature
  - Icons and brief descriptions
- **Secondary CTA Section**
  - Additional call-to-action to drive conversions
  - Social proof (testimonials, user counts, etc.)
  - Sign up incentives
- **Navigation**
  - Top navigation bar
  - Links to: Home, Features, Pricing (if applicable), About
  - Sign In / Register buttons prominently displayed
- **Footer**
  - Links to documentation, support, social media
  - Legal links (Terms, Privacy)
  - Newsletter signup (optional)

### Authenticated Users (Application)

#### Main Application Layout

```
┌──────────┬──────────────────────────────────────┐
│          │                                      │
│          │                                      │
│ Sidebar  │     Main Content Area               │
│ (Left)   │                                      │
│          │                                      │
│          │                                      │
│          │                                      │
└──────────┴──────────────────────────────────────┘
```

#### Sidebar (Left)

- **Fixed/collapsible sidebar**
- **Navigation Menu** (top)
  - Dashboard/Home
  - Campaigns
  - Worlds
  - Systems
  - Search
  - Notifications
- **Quick Actions** (middle, optional)
  - Create New Campaign
  - Create New World
  - Create New System
- **User Profile Section** (bottom)
  - Avatar
  - Username
  - Settings
  - Help/Documentation
  - Sign Out

#### Main Content Area (Right)

- **Flexible content area** that adapts based on current view
- **Breadcrumb navigation** at top (when applicable)
- **Page header** with title and actions
- **Content body** - varies by page/feature
- **Responsive** - sidebar collapses to hamburger menu on mobile

#### Mobile Considerations

- Sidebar converts to slide-out drawer/hamburger menu
- Touch-friendly tap targets
- Optimized spacing for smaller screens
- Bottom navigation bar (alternative to sidebar)

## Design Principles

- **Clean and Modern** - Minimalist aesthetic with focus on content
- **Intuitive Navigation** - Easy to find and access features
- **Consistent** - Reusable components and patterns
- **Accessible** - WCAG 2.1 AA compliance
- **Responsive** - Mobile-first approach

## Color Scheme

_To be defined_

## Typography

_To be defined_

## Component Library

_To be defined_
