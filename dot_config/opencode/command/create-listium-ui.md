---
description: Create a UI component or page following Listium design system
---

# Task: Create Listium UI

Create the following UI component or page: "$ARGUMENTS"

Follow these strict design specifications to ensure it matches the application's core aesthetic.

## Design Specifications

### 1. Page Layout
- **Container**: `flex h-full flex-col bg-muted/5`
- **Header**: 
  - Wrapper: `flex items-center justify-between border-b border-border px-4 py-4 md:px-8 md:py-6`
  - Title: `text-xl font-bold tracking-tight text-foreground md:text-2xl`
  - Subtitle: `text-sm text-muted-foreground` (hidden on mobile if needed)
- **Content Body**: `flex-1 overflow-y-auto p-4 md:p-8`

### 2. Card Component Style
- **Wrapper**: `group relative flex flex-col overflow-hidden rounded-2xl border border-border bg-card transition-all duration-300 hover:border-ring/50 hover:shadow-lg`
- **Image/Hero**: 
  - Aspect ratio or fixed height (`h-24` to `h-40`)
  - `border-b border-border/50`
  - Gradient overlay for text contrast: `bg-gradient-to-t from-black/60 via-black/20 to-transparent`
- **Internal Padding**: `p-4 md:p-5`
- **Typography**:
  - Headings: `text-base font-semibold text-foreground`
  - Secondary: `text-xs text-muted-foreground`
- **Badges**: `rounded-full border border-border bg-muted/50 px-2.5 py-1 text-[10px] font-medium text-muted-foreground`

### 3. Data/Stats Grid (Inside Cards)
- **Container**: `rounded-xl border border-border/50 bg-muted/20`
- **Layout**: `grid grid-cols-3 divide-x divide-border/50` (or cols-2 depending on data)
- **Items**: Centered text
- **Values**: `text-base font-semibold text-foreground`
- **Labels**: `text-[9px] font-medium uppercase tracking-wider text-muted-foreground`

### 4. Empty States
- **Container**: `rounded-2xl border border-dashed border-border bg-card text-center shadow-sm`
- **Icon**: Large icon in a circle (`bg-muted ring-1 ring-border`)
- **Typography**: Clear heading (`text-lg font-medium`) and helper text (`text-sm text-muted-foreground`)
- **Action**: Primary button centered below text

### 5. Mobile & Dark Mode Requirements
- **Mobile**:
  - Touch targets must be accessible (min 44px height for buttons/inputs).
  - Fonts should not be smaller than `text-[10px]` for metadata, `text-xs` for secondary.
  - Grids must collapse to single column (`grid-cols-1`) on mobile.
- **Dark Mode**:
  - Use semantic colors (`bg-card`, `bg-muted`) exclusively.
  - Never use raw blacks or whites.
  - Borders should be subtle (`border-border`) but interactive states can be brighter (`border-ring`).

## Implementation Checklist
- [ ] Use `"use client"` for interactive components.
- [ ] Use `lucide-react` for icons.
- [ ] Use `shadcn/ui` primitives (Button, Badge, etc.).
- [ ] Ensure full responsiveness (mobile -> desktop).
- [ ] Verify dark mode contrast.
