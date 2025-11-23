# TypeScript Best Practices for OpenCode Agents

This document outlines strict TypeScript guidelines that all OpenCode agents should follow when generating or modifying TypeScript code.

## Core Principles

### 1. Never Use `any` Type
- **Rule**: Absolutely no usage of `any` type
- **Alternative**: Use `unknown`, `never`, or proper union types
- **Example**: Instead of `const data: any = response`, use `const data: unknown = response`

### 2. Never Use Non-Null Assertions
- **Rule**: Avoid `!` operator (e.g., `value!`, `element!`)
- **Alternative**: Use proper null checking, optional chaining, or type guards
- **Example**: Instead of `user.name!`, use `user.name ?? 'default'` or check `if (user.name)`

### 3. Strict Type Safety
- **Rule**: Enable and respect all TypeScript strict mode options
- **Practice**: Use `strictNullChecks`, `strictFunctionTypes`, `strictBindCallApply`
- **Approach**: Let TypeScript catch errors at compile time, not runtime

### 4. No Type Casting Unless Absolutely Necessary
- **Rule**: Avoid type assertions (`as Type`, `<Type>`)
- **Exception**: Only when dealing with external APIs or DOM manipulation
- **Alternative**: Use type guards, predicates, or refactor code structure

## Testing Guidelines

### 5. Don't Test Implementation Details
- **Rule**: Test behavior, not internal implementation
- **Focus**: Test what the code does, not how it does it
- **Example**: Test component renders correctly, not which internal methods it calls

### 6. Test Public APIs Only
- **Rule**: Only test exported functions and public methods
- **Avoid**: Testing private functions, internal state, or helper methods
- **Exception**: Complex internal logic that needs isolated testing

## Type Design

### 7. Make Types as Strict as Possible
- **Rule**: Be maximally restrictive with types
- **Practice**: Use literal types, branded types, and exact object types
- **Example**: Use `'red' | 'blue' | 'green'` instead of `string`

### 8. Prefer Discriminated Unions
- **Rule**: Use discriminated unions over generic strings or loose types
- **Benefit**: Better type narrowing and exhaustiveness checking
- **Example**:
```typescript
type Action = 
  | { type: 'increment'; amount: number }
  | { type: 'decrement'; amount: number }
  | { type: 'reset' };
```

### 9. Use Type Predicates and Guards
- **Rule**: Create proper type guards instead of casting
- **Example**:
```typescript
function isString(value: unknown): value is string {
  return typeof value === 'string';
}
```

## Code Structure

### 10. Explicit Return Types
- **Rule**: Specify return types for functions
- **Benefit**: Better documentation and type safety
- **Example**: `function calculateTotal(items: Item[]): number`

### 11. Avoid Optional Properties When Possible
- **Rule**: Use required properties with proper default values
- **Alternative**: Use union types with `undefined` when truly optional

### 12. Generic Constraints
- **Rule**: Use proper generic constraints instead of loose generics
- **Example**: `function process<T extends Record<string, unknown>>(data: T)`

## Error Handling

### 13. Always Properly Handle Errors
- **Rule**: Never ignore errors or use empty catch blocks
- **Practice**: Always handle errors explicitly with proper typing
- **Example**: Instead of `try { ... } catch { }`, use `try { ... } catch (error) { /* handle appropriately */ }`

### 14. Use Result Types for Expected Errors
- **Rule**: Use Result/Either types for operations that can fail expectedly
- **Benefit**: Makes error handling explicit and forces handling
- **Example**:
```typescript
type Result<T, E> = { success: true; data: T } | { success: false; error: E };

function parseJson(json: string): Result<object, SyntaxError> {
  try {
    return { success: true, data: JSON.parse(json) };
  } catch (error) {
    return { success: false, error: error as SyntaxError };
  }
}
```

### 15. Never Throw Generic Errors
- **Rule**: Always throw specific error types with meaningful messages
- **Practice**: Create custom error classes for different error scenarios
- **Example**:
```typescript
class ValidationError extends Error {
  constructor(public field: string, message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

class NetworkError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
    this.name = 'NetworkError';
  }
}
```

### 16. Handle Async Errors Properly
- **Rule**: Always await promises and handle rejections
- **Practice**: Use try-catch for async/await, .catch() for promises
- **Example**:
```typescript
// Good
async function fetchData() {
  try {
    const response = await fetch('/api/data');
    return await response.json();
  } catch (error) {
    if (error instanceof NetworkError) {
      // Handle network error
    }
    throw error; // Re-throw if can't handle
  }
}

// Bad - unhandled promise rejection
function fetchDataBad() {
  return fetch('/api/data').then(r => r.json()); // No error handling!
}
```

### 17. Use Error Boundaries for React Components
- **Rule**: Wrap components with error boundaries to catch rendering errors
- **Practice**: Create proper error boundary components with fallback UI
- **Example**:
```typescript
class ErrorBoundary extends React.Component<Props, State> {
  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }
  
  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

### 18. Exhaustive Switch Statements
- **Rule**: Handle all cases in switch statements
- **Tool**: Use `never` type for exhaustive checking
- **Example**:
```typescript
function handleAction(action: Action) {
  switch (action.type) {
    case 'increment': return action.amount;
    case 'decrement': return -action.amount;
    case 'reset': return 0;
    default: 
      const _exhaustive: never = action;
      throw new Error(`Unhandled action: ${_exhaustive}`);
  }
}
```

## Best Practices Summary

✅ **Do**:
- Use strict TypeScript configuration
- Create specific, restrictive types
- Use type guards and predicates
- Test behavior, not implementation
- Specify explicit return types
- Use discriminated unions
- Handle all error cases
- Use Result types for expected failures
- Throw specific error types
- Always handle async errors properly
- Use error boundaries for React components

❌ **Don't**:
- Use `any` type
- Use non-null assertions (`!`)
- Cast types unnecessarily
- Test private implementation details
- Use loose or generic types when specific ones work
- Leave optional properties undefined when they could have defaults
- Ignore errors with empty catch blocks
- Throw generic Error instances
- Leave promises unhandled
- Swallow errors without proper handling

## Agent Instructions

When generating TypeScript code, agents should:
1. Always start with the strictest possible types
2. Gradually relax constraints only when necessary
3. Prefer compile-time safety over runtime flexibility
4. Create types that make incorrect states unrepresentable
5. Use TypeScript's type system to enforce business rules

Remember: Good TypeScript code should make it impossible to represent invalid states.

## Next.js Development with MCP Tools

When working on Next.js projects, you have access to powerful MCP tools through the `next-devtools` server:

### When to Initialize

**IMPORTANT**: At the start of every Next.js session, call the `init` tool from `next-devtools` to:
- Set up proper context for Next.js development
- Establish requirement to use `nextjs_docs` for ALL Next.js-related queries
- Understand available tools and workflows

### Available Tools

1. **`nextjs_docs`** - Search and retrieve official Next.js documentation
   - **When to use**: For ANY Next.js-related questions, API lookups, or best practices
   - **Example**: "Search Next.js docs for generateMetadata"

2. **`nextjs_runtime`** (Next.js 16+ only) - Access live dev server diagnostics
   - **When to use**: When dev server is running and you need to check:
     - Current errors or warnings
     - Application routes and structure
     - Dev server logs
     - Server Actions by ID
   - **Example**: "What errors are in my Next.js app?"

3. **`browser_eval`** - Browser automation via Playwright
   - **When to use**: For visual verification, testing user flows, or screenshots
   - **Note**: For Next.js projects, prefer `nextjs_runtime` for error detection
   - **Example**: "Take a screenshot of the homepage"

4. **`upgrade_nextjs_16`** - Automated Next.js 16 upgrade
   - **When to use**: Upgrading from Next.js 15 or earlier to Next.js 16
   - **Example**: "Help me upgrade to Next.js 16"

5. **`enable_cache_components`** - Cache Components migration
   - **When to use**: Enabling Cache Components mode in Next.js 16
   - **Example**: "Enable Cache Components in my app"

### Best Practices

- **Documentation First**: Always use `nextjs_docs` to search for official guidance before implementing Next.js features
- **Runtime Diagnostics**: For Next.js 16+, use `nextjs_runtime` to check errors instead of browser console logs
- **Auto-Initialize**: The `init` tool should be called automatically at session start (configure in agent settings)

## General Documentation Search with Context7

When you need to search through documentation for ANY technology, framework, or library (not just Next.js), use the `context7` MCP tools:

### When to Use Context7

- **Technology Documentation**: Search docs for Cloudflare Workers, React, TypeScript, etc.
- **API References**: Find specific API methods and usage examples
- **Best Practices**: Look up recommended patterns and approaches
- **Configuration Help**: Find setup and configuration guidance

### Usage

Simply add "use context7" to your prompts:
- "Configure a Cloudflare Worker script to cache JSON API responses for five minutes. use context7"
- "How do I set up TypeScript strict mode? use context7"
- "Best practices for React Server Components. use context7"

### Rate Limits

Context7 works without an API key but has rate limits. For higher limits:
1. Sign up for a free account at [context7.com](https://context7.com)
2. Set the environment variable: `export CONTEXT7_API_KEY="your_api_key"`