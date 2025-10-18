# Novel Characters' Personality Analyzer

An NLP pipeline to extract and analyze **fictional characters’ personality traits** from classic literature.  
The system uses **Named Entity Recognition (NER)** and **dependency parsing** to detect character mentions, group name variants, and associate adjectives with personality dimensions.

## Highlights
- Fetches and preprocesses books from **Project Gutenberg**.
- Identifies characters via **spaCy NER** and groups name variants.
- Extracts adjectives linked to characters and maps them to traits using a custom **trait–adjective lexicon**.
- Demonstrates applications on *Frankenstein* and *The Betrothed*.
