# Enrichment Pipeline

## Overview
The Enrichment Pipeline is a sequence of screens designed to enhance contact data after the initial selection or import process. This flow ensures that contacts have necessary metadata such as priority levels and location information, which are crucial for the application's core features.

## Flow Hierarchy
1. **EnrichInfoScreen**: The entry point to the enrichment process. It educates the user on why enrichment is needed (Priority & Location).
2. **PriorityEnrichInfoScreen**: Explains the priority levels and initiates the priority assignment flow.
3. **Location Enrichment** (Planned): Will handle geocoding and location assignment.

## Screens

### EnrichInfoScreen
- **Purpose**: Introduction to the enrichment phase.
- **Key Elements**:
  - Title: "Enrich Data"
  - Explanatory text for Priority and Location enrichment.
  - "Get Started" button to proceed.

### PriorityEnrichInfoScreen
- **Purpose**: Inform user about priority levels before assignment.
- **Key Elements**:
  - Title: "Select Priority"
  - Description of High, Medium, and Low priority levels.
  - "Enrich Priorities" button to start the assignment process.

## Data Flow
- Data is passed from the Contact Selection/Import screens into this pipeline.
- The pipeline modifies the `Contact` models by updating their `priority` and `location` properties.
- Once enrichment is complete, contacts are saved to the persistent store.
