---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: text-processing
  displayName: Text Processing
  version: 1.0.0
  description: Extract entities, classify text, detect PII, and process natural language
  category: NLP
  tags: [nlp, entity, pii, keywords, similarity, language, regex]
  icon: text
tools:
  - name: extract_entities
    description: Extract named entities (people, organizations, locations, dates) from text
    category: extraction
  - name: classify_text
    description: Classify text into predefined categories using keyword and pattern matching
    category: classification
  - name: extract_keywords
    description: Extract key terms and phrases from text using TF-IDF or frequency analysis
    category: extraction
  - name: tokenize_text
    description: Split text into tokens (words, sentences, or n-grams) with configurable rules
    category: tokenization
  - name: similarity_score
    description: Calculate similarity between two text strings using cosine or Jaccard metrics
    category: analysis
  - name: redact_pii
    description: Detect and redact personally identifiable information from text
    category: security
  - name: extract_structured_data
    description: Extract structured key-value pairs from unstructured text using patterns
    category: extraction
  - name: language_detect
    description: Detect the language of input text
    category: detection
  - name: text_chunk
    description: Split text into chunks of a target size with configurable overlap
    category: chunking
  - name: regex_extract
    description: Extract matches from text using a regular expression pattern
    category: extraction
---

# Text Processing

Extract entities, classify text, detect PII, and process natural language. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent that analyzes, transforms, or validates text content.

## Use Cases

- Extract named entities from customer support tickets
- Redact PII from documents before sharing or storage
- Classify incoming messages by topic or intent
- Chunk long documents for embedding or summarization
- Detect the language of user-submitted content

## Tools

### extract_entities
Extract named entities (person, organization, location, date, money) from text using pattern-based recognition.

### classify_text
Classify text into one or more categories using keyword matching, regex patterns, or rule-based scoring.

### extract_keywords
Extract the most important terms from text using TF-IDF scoring or simple frequency analysis.

### tokenize_text
Split text into words, sentences, or n-grams with configurable delimiters and normalization rules.

### similarity_score
Calculate textual similarity between two strings using cosine similarity, Jaccard index, or Levenshtein distance.

### redact_pii
Detect and replace PII (emails, phone numbers, SSNs, credit cards, names) with configurable redaction markers.

### extract_structured_data
Parse key-value pairs, addresses, or structured fields from free-form text using pattern templates.

### language_detect
Identify the language of input text from character n-gram frequency profiles.

### text_chunk
Split text into chunks of a target token or character count with configurable overlap for context preservation.

### regex_extract
Apply a regular expression to text and return all matches with capture group values.
