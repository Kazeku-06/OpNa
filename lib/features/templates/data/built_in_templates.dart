import 'package:uuid/uuid.dart';
import '../domain/entities/note_template.dart';

class BuiltInTemplates {
  static const Uuid _uuid = Uuid();

  static List<NoteTemplate> getBuiltInTemplates() {
    final now = DateTime.now();

    return [
      NoteTemplate(
        id: _uuid.v4(),
        name: 'Daily Journal',
        content: '''# Daily Journal - {{date}}

## Today's Focus
- 

## What Happened
- 

## Thoughts & Reflections
- 

## Tomorrow's Priorities
- 

---
*Created: {{time}}*''',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),

      NoteTemplate(
        id: _uuid.v4(),
        name: 'Meeting Notes',
        content: '''# Meeting Notes - {{date}}

**Meeting:** 
**Attendees:** 
**Date:** {{date}}
**Time:** {{time}}

## Agenda
- 

## Discussion Points
- 

## Action Items
- [ ] 
- [ ] 
- [ ] 

## Next Steps
- 

## Follow-up
- ''',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),

      NoteTemplate(
        id: _uuid.v4(),
        name: 'Study Notes',
        content: '''# Study Notes - {{subject}}

**Subject:** 
**Date:** {{date}}
**Source:** 

## Key Concepts
- 

## Important Points
- 

## Examples
- 

## Questions
- 

## Summary
- 

## Review Date
- [ ] {{next_week}}''',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),

      NoteTemplate(
        id: _uuid.v4(),
        name: 'Project Planning',
        content: '''# Project: {{project_name}}

**Start Date:** {{date}}
**Deadline:** 
**Status:** Planning

## Objective
- 

## Requirements
- [ ] 
- [ ] 
- [ ] 

## Milestones
- [ ] **Phase 1:** 
- [ ] **Phase 2:** 
- [ ] **Phase 3:** 

## Resources Needed
- 

## Risks & Mitigation
- 

## Notes
- ''',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),

      NoteTemplate(
        id: _uuid.v4(),
        name: 'Book Notes',
        content: '''# Book Notes: {{book_title}}

**Author:** 
**Genre:** 
**Started:** {{date}}
**Finished:** 

## Summary
- 

## Key Takeaways
- 

## Favorite Quotes
> 

## My Thoughts
- 

## Rating
⭐⭐⭐⭐⭐ ( /5)

## Related Books
- [[]]''',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
    ];
  }

  static String processTemplate(String content) {
    final now = DateTime.now();
    final replacements = {
      '{{date}}': _formatDate(now),
      '{{time}}': _formatTime(now),
      '{{next_week}}': _formatDate(now.add(const Duration(days: 7))),
    };

    String processed = content;
    replacements.forEach((placeholder, value) {
      processed = processed.replaceAll(placeholder, value);
    });

    return processed;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
