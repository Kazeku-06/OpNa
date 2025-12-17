# Architecture Documentation

## Overview

This Offline Markdown Notes App implements a **Clean Architecture** pattern with **offline-first** design principles. The architecture prioritizes data durability, performance, and maintainability over complex features.

## Core Principles

### 1. Offline-First Design
- **No network dependencies** - App works completely offline
- **Local storage only** - All data stored on device
- **Immediate availability** - No loading states for network calls
- **Data durability** - Multiple layers of data protection

### 2. Clean Architecture
```
┌─────────────────────────────────────────┐
│              Presentation               │
│  (Screens, Widgets, Providers)         │
├─────────────────────────────────────────┤
│               Domain                    │
│     (Entities, Repositories)           │
├─────────────────────────────────────────┤
│                Data                     │
│  (Repository Implementations)           │
├─────────────────────────────────────────┤
│                Core                     │
│   (File Manager, Constants)             │
└─────────────────────────────────────────┘
```

### 3. Hybrid Storage Strategy
- **Metadata in Hive** - Fast queries, indexing, relationships
- **Content in Files** - Prevents database bloat, easier backup
- **Versions as Files** - Simple versioning, efficient diffs

## Layer Details

### Presentation Layer
**Location**: `lib/features/notes/presentation/`

**Responsibilities**:
- UI components and screens
- State management with Riverpod
- User interaction handling
- Navigation logic

**Key Components**:
- **Providers**: Reactive state management
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

**State Management Flow**:
```
User Action → Provider → Repository → File System/Hive
                ↓
UI Update ← State Change ← Data Change
```

### Domain Layer
**Location**: `lib/features/notes/domain/`

**Responsibilities**:
- Business entities (Note, NoteVersion)
- Repository interfaces
- Business logic rules

**Key Entities**:
- **Note**: Core note metadata
- **NoteVersion**: Version history data
- **Repository Interface**: Data access contract

### Data Layer
**Location**: `lib/features/notes/data/`

**Responsibilities**:
- Repository implementations
- Data source coordination
- Error handling and recovery

**Data Sources**:
- **Hive Database**: Note metadata
- **File System**: Note content and versions
- **File Manager**: Centralized file operations

### Core Layer
**Location**: `lib/core/`

**Responsibilities**:
- Cross-cutting concerns
- File system management
- App-wide constants
- Utility functions

## Storage Architecture

### Metadata Storage (Hive)
```dart
Note {
  String id;              // UUID primary key
  String title;           // Note title
  DateTime createdAt;     // Creation timestamp
  DateTime updatedAt;     // Last modification
  bool isPinned;          // Pin status
  String? folder;         // Optional folder
  int currentVersion;     // Current version number
  int nextVersionNumber;  // Next version to create
}
```

**Why Hive?**
- Fast local queries
- Type-safe with code generation
- Efficient indexing
- No SQL complexity
- Automatic serialization

### Content Storage (File System)
```
/app_documents/
├── notes/
│   ├── {uuid}.md           # Current note content
│   └── ...
├── versions/
│   ├── {uuid}/
│   │   ├── v1.md          # Version snapshots
│   │   ├── v2.md
│   │   └── ...
│   └── ...
└── backups/
    └── backup_{timestamp}.zip
```

**Why File System?**
- No size limits for content
- Easy backup and export
- Version control simplicity
- Better performance for large content
- Platform file system integration

## Data Flow Patterns

### 1. Note Creation Flow
```
User Input → Create Note Provider → Repository
    ↓
Generate UUID → Save Metadata (Hive) → Create Content File
    ↓
Update UI State ← Return Note Entity
```

### 2. Content Editing Flow
```
User Types → Content Provider → Autosave Timer
    ↓
Save to File System → Update Metadata Timestamp
    ↓
UI State Update (Auto-saving indicator)
```

### 3. Version Control Flow
```
Manual Save → Current Content → Create Version File
    ↓
Update Note Metadata → Increment Version Numbers
    ↓
Cleanup Old Versions (if > 50) → Update UI
```

### 4. Search Flow
```
User Query → Debounce Timer → Search Provider
    ↓
Search Metadata (Hive) + Search Files (File System)
    ↓
Combine Results → Limit to 100 → Update UI
```

## Performance Optimizations

### 1. Lazy Loading
- Note content loaded only when needed
- Version history loaded on demand
- Search results paginated

### 2. Efficient Queries
- Hive indexing for fast metadata queries
- File system search with early termination
- Debounced search to prevent excessive queries

### 3. Memory Management
- Content not kept in memory unnecessarily
- Version cleanup to prevent storage bloat
- Efficient file operations with proper disposal

### 4. Caching Strategy
- Riverpod automatic caching
- File system caching by OS
- No manual cache management needed

## Error Handling Strategy

### 1. File System Errors
```dart
try {
  await fileOperation();
} catch (e) {
  throw FileSystemException('User-friendly message: $e');
}
```

### 2. Data Corruption Recovery
- Graceful degradation for corrupted files
- Backup restoration capabilities
- User notification with recovery options

### 3. Storage Full Scenarios
- Clear error messages
- Cleanup suggestions
- Graceful app continuation

### 4. Concurrent Access
- File locking where necessary
- Atomic operations for critical data
- Retry mechanisms for temporary failures

## Security Considerations

### 1. Data Privacy
- All data stored locally
- No network transmission
- No analytics or tracking
- User controls all data

### 2. File System Security
- App-sandboxed storage
- Platform security model
- No external file access
- Secure backup creation

## Scalability Considerations

### 1. Note Volume
- **Tested**: 1000+ notes
- **Bottlenecks**: Search performance, UI rendering
- **Solutions**: Pagination, virtual scrolling, indexed search

### 2. Content Size
- **Limit**: Platform file system limits
- **Considerations**: Large files impact editor performance
- **Solutions**: Chunked loading, performance warnings

### 3. Version History
- **Limit**: 50 versions per note (configurable)
- **Cleanup**: Automatic old version removal
- **Storage**: Efficient diff-based storage possible

## Extension Points

### 1. New Storage Backends
- Repository pattern allows easy swapping
- Interface-based design
- Minimal impact on other layers

### 2. Additional Features
- Plugin architecture possible
- Provider-based feature flags
- Modular component design

### 3. Platform-Specific Features
- File manager integration
- Platform-specific UI components
- Native file operations

## Testing Strategy

### 1. Unit Tests
- Entity business logic
- Repository implementations
- File operations
- Provider state management

### 2. Integration Tests
- Full user workflows
- Data persistence
- Error scenarios
- Performance benchmarks

### 3. Widget Tests
- UI component behavior
- User interactions
- State updates
- Navigation flows

## Deployment Considerations

### 1. Platform Differences
- File system paths
- Storage permissions
- Performance characteristics
- UI adaptations

### 2. Migration Strategy
- Version-compatible data formats
- Backward compatibility
- Migration scripts for major changes
- User data preservation

### 3. Performance Monitoring
- App startup time
- Search performance
- Memory usage
- Storage usage

This architecture provides a solid foundation for a production-ready notes application while maintaining simplicity and focusing on reliability over complexity.