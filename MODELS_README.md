# Civic Track Models & Features

## Overview
This document outlines the data models and features implemented for the Civic Track application, focusing on civic engagement and issue reporting.

## Models Created

### 1. Report Class (`lib/models/report.dart`)
The main class for civic issues/reports containing:

**Core Properties:**
- `id`: Unique identifier
- `title`: Issue title/summary
- `description`: Detailed description
- `reporterUserId`, `reporterUserName`, `reporterUserImage`: Reporter information
- `imageUrls`: List of attached images
- `category`: Issue category (enum)
- `status`: Current status (enum)
- `createdAt`, `updatedAt`: Timestamps
- `location`, `latitude`, `longitude`: Location data
- `statusHistory`: Complete audit trail
- `upvotes`, `downvotes`: Community voting
- `upvotedBy`, `downvotedBy`: User tracking for votes

**Key Features:**
- Immutable updates with `copyWith()` method
- JSON serialization/deserialization
- Helper methods for time formatting and user voting checks
- Complete audit trail for transparency

### 2. IssueCategory Enum (`lib/models/issue_category.dart`)
Comprehensive categorization system with 12 categories:

**Categories:**
- **Infrastructure** 🏗️ - Roads, bridges, utilities
- **Environment** 🌱 - Pollution, waste, green spaces
- **Public Safety** 🚨 - Crime, lighting, emergency services
- **Transportation** 🚌 - Public transport, traffic, parking
- **Public Services** 🏥 - Healthcare, education, social services
- **Governance** ⚖️ - Corruption, transparency, accountability
- **Community** 👥 - Events, volunteer opportunities
- **Utilities** ⚡ - Water, electricity, internet
- **Housing** 🏠 - Affordable housing, development
- **Health** 🏥 - Public health issues, sanitation
- **Education** 📚 - Schools, libraries, learning resources
- **Other** ❓ - Issues not covered by other categories

**Features:**
- Color coding for UI consistency
- Icons for visual representation
- Urgency classification
- Emoji support for engagement

### 3. ReportStatus Enum (`lib/models/report_status.dart`)
Complete workflow management with 10 status states:

**Status Flow:**
1. **Submitted** - Initial state
2. **Under Review** - Admin reviewing
3. **Investigating** - Authority investigation
4. **In Progress** - Active work
5. **Resolved** - Issue fixed
6. **Rejected** - Not valid/actionable
7. **Duplicate** - Already reported
8. **Needs More Info** - Awaiting user input
9. **Escalated** - Higher priority
10. **On Hold** - Temporarily paused

**Features:**
- Smart status transitions (next possible states)
- Time estimates for resolution
- Color coding and icons
- Active vs. final state classification

### 4. StatusChangeLog Class (`lib/models/report.dart`)
Complete transparency through audit logging:

**Properties:**
- Status transitions (from/to)
- Change attribution (who, when)
- Reason and admin notes
- Formatted timestamps

**Transparency Features:**
- Complete history preservation
- Admin accountability
- Public visibility of all changes
- Timestamped for legal compliance

### 5. ReportNotification Class (`lib/models/notification.dart`)
Comprehensive notification system:

**Notification Types:**
- Status updates
- New comments
- Community upvotes
- Issue escalations
- Final resolutions
- Admin messages

**Features:**
- Factory constructors for different notification types
- Read/unread state management
- Rich notification content with context
- Time-based formatting

## UI Components

### 1. CivicPostCard Widget (`lib/widgets/civic_post_card.dart`)
Enhanced social media-style card with:
- User information display
- Post images with error handling
- Engagement buttons (like, comment, share)
- 3-dot menu with report functionality
- Loading states and error handling

### 2. IssueDetailPage (`lib/screens/issue_detail_page.dart`)
Comprehensive issue detail view featuring:

**Visual Elements:**
- Gradient header with status badge
- Category and timing information
- Reporter profile section
- Image gallery with error handling
- Location display
- Community voting visualization

**Transparency Features:**
- Complete status history timeline
- Timestamped changes with admin notes
- Visual status progression
- Admin accountability display

## Key Features Implemented

### 1. Complete Transparency
- **Status History**: Every status change is logged with timestamp, who made the change, and why
- **Admin Notes**: Administrators can add context to status changes
- **Public Visibility**: All changes are visible to reporters and community
- **Audit Trail**: Complete history preservation for accountability

### 2. Community Engagement
- **Voting System**: Community can upvote/downvote issues for priority
- **Social Features**: Like, comment, share functionality
- **Reporting**: Users can report inappropriate content
- **Category-based Organization**: Issues organized by clear categories

### 3. Smart Workflow Management
- **Status Transitions**: Only valid next statuses are allowed
- **Time Estimates**: Realistic timeline expectations
- **Escalation Path**: Clear escalation when needed
- **Hold States**: Ability to pause work with reasoning

### 4. Notification System
- **Real-time Updates**: Reporters notified of all status changes
- **Rich Context**: Notifications include relevant details
- **Multiple Types**: Different notification types for different events
- **Read State Management**: Track notification read status

### 5. Data Integrity
- **Immutable Models**: Safe state updates with copyWith
- **JSON Serialization**: Database storage ready
- **Type Safety**: Enum-based categories and statuses
- **Validation Ready**: Structure supports validation rules

## Usage Examples

### Creating a Report
```dart
final report = Report(
  id: 'unique_id',
  title: 'Pothole on Main Street',
  description: 'Large pothole causing vehicle damage',
  reporterUserId: 'user_123',
  reporterUserName: 'John Doe',
  imageUrls: ['image1.jpg', 'image2.jpg'],
  category: IssueCategory.infrastructure,
  status: ReportStatus.submitted,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  statusHistory: [],
  upvotedBy: [],
  downvotedBy: [],
);
```

### Updating Status
```dart
final updatedReport = report.copyWith(
  status: ReportStatus.inProgress,
  updatedAt: DateTime.now(),
  statusHistory: [...report.statusHistory, newStatusLog],
);
```

### Creating Notifications
```dart
final notification = ReportNotification.statusUpdate(
  id: 'notif_123',
  userId: report.reporterUserId,
  reportId: report.id,
  reportTitle: report.title,
  fromStatus: ReportStatus.investigating,
  toStatus: ReportStatus.inProgress,
  changedByName: 'City Worker',
  adminNotes: 'Work has begun on the repair',
);
```

## Next Steps
1. Database integration for persistence
2. Real-time notification delivery system
3. Admin dashboard for status management
4. Advanced filtering and search
5. Analytics and reporting features
6. Integration with city systems
7. Mobile push notifications
8. Email notification fallbacks
