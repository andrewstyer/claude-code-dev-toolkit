const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');

// Paths
const SAMPLE_DATA_DIR = path.join(__dirname, '..', 'assets', 'sample-data');
const OUTPUT_DB_PATH = path.join(SAMPLE_DATA_DIR, 'sample-health-narrative.db');
const JSON_DATA_PATH = path.join(SAMPLE_DATA_DIR, 'sarah-chen-data.json');

console.log('🏗️  Building sample database...');
console.log(`📂 Output: ${OUTPUT_DB_PATH}`);

interface SampleDocument {
  id: string;
  title: string;
  category: string;
  date: string;
  provider?: string;
  fileName: string;
  mimeType: string;
  needsReview?: boolean;
  inferenceSource?: string;
  isSampleData: boolean;
}

interface SampleEvent {
  id: string;
  title: string;
  description?: string;
  date: string;
  category: string;
  type: 'health_event' | 'life_event';
  linkedDocuments?: string[];
  isSampleData: boolean;
}

interface SampleData {
  metadata: {
    persona: string;
    version: string;
    totalEvents: number;
    totalDocuments: number;
  };
  timelineEvents: SampleEvent[];
  documents: SampleDocument[];
}

function createSchema(db: any): void {
  console.log('📋 Creating schema...');

  db.exec(`
    -- Documents table (matches src/core/database/schema.ts)
    CREATE TABLE IF NOT EXISTS documents (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      date_occurred TEXT NOT NULL,
      date_added TEXT NOT NULL,
      provider TEXT,
      file_path TEXT NOT NULL,
      file_type TEXT NOT NULL,
      file_size INTEGER,
      extracted_text TEXT,
      notes TEXT,
      needs_review INTEGER DEFAULT 0,
      inference_source TEXT,
      is_sample_data INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    -- Timeline events table (matches src/core/database/schema.ts)
    CREATE TABLE IF NOT EXISTS timeline_events (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      date TEXT NOT NULL,
      category TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('health_event', 'life_event')),
      is_sample_data INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    -- Event-document junction table (matches src/core/database/schema.ts)
    CREATE TABLE IF NOT EXISTS event_documents (
      event_id TEXT NOT NULL,
      document_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (event_id, document_id),
      FOREIGN KEY (event_id) REFERENCES timeline_events(id) ON DELETE CASCADE,
      FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
    );

    -- Indexes (matches src/core/database/schema.ts)
    CREATE INDEX IF NOT EXISTS idx_documents_date ON documents(date_occurred DESC);
    CREATE INDEX IF NOT EXISTS idx_documents_category ON documents(category);
    CREATE INDEX IF NOT EXISTS idx_documents_sample ON documents(is_sample_data);
    CREATE INDEX IF NOT EXISTS idx_documents_needs_review ON documents(needs_review);
    CREATE INDEX IF NOT EXISTS idx_events_date ON timeline_events(date DESC);
    CREATE INDEX IF NOT EXISTS idx_events_type ON timeline_events(type);
    CREATE INDEX IF NOT EXISTS idx_events_category ON timeline_events(category);
    CREATE INDEX IF NOT EXISTS idx_events_sample ON timeline_events(is_sample_data);
    CREATE INDEX IF NOT EXISTS idx_event_documents_event ON event_documents(event_id);
    CREATE INDEX IF NOT EXISTS idx_event_documents_document ON event_documents(document_id);
  `);

  // Set schema version to match app migrations
  db.pragma('user_version = 1');

  console.log('✅ Schema created');
}

function insertDocuments(db: any, documents: SampleDocument[]): void {
  console.log(`📄 Inserting ${documents.length} documents...`);

  const insertStmt = db.prepare(`
    INSERT INTO documents (
      id, title, category, date_occurred, date_added, provider,
      file_path, file_type, file_size, extracted_text, notes,
      needs_review, inference_source, is_sample_data, created_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const insertMany = db.transaction((docs: SampleDocument[]) => {
    for (const doc of docs) {
      // Use placeholder for FileSystem path - replaced at runtime
      const filePath = `{DOCUMENT_DIR}/${doc.fileName}`;

      // Use current timestamp for created_at and updated_at
      const now = new Date().toISOString();

      insertStmt.run(
        doc.id,
        doc.title,
        doc.category,
        doc.date,           // date_occurred
        doc.date,           // date_added (same as occurred for sample data)
        doc.provider || null,
        filePath,           // file_path
        doc.mimeType,       // file_type
        null,               // file_size (will be calculated at runtime)
        null,               // extracted_text (will be extracted at runtime)
        null,               // notes (empty for sample data)
        doc.needsReview ? 1 : 0,  // needs_review
        doc.inferenceSource || null,  // inference_source
        1,                  // is_sample_data
        now,                // created_at
        now                 // updated_at
      );
    }
  });

  insertMany(documents);

  console.log(`✅ Inserted ${documents.length} documents`);
}

function insertEvents(db: any, events: SampleEvent[]): void {
  console.log(`📅 Inserting ${events.length} events...`);

  const insertStmt = db.prepare(`
    INSERT INTO timeline_events (
      id, title, description, date, category, type, is_sample_data, created_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const insertMany = db.transaction((evts: SampleEvent[]) => {
    for (const event of evts) {
      // Use current timestamp for created_at and updated_at
      const now = new Date().toISOString();

      insertStmt.run(
        event.id,
        event.title,
        event.description || null,
        event.date,
        event.category,
        event.type,
        1,          // is_sample_data
        now,        // created_at
        now         // updated_at
      );
    }
  });

  insertMany(events);

  console.log(`✅ Inserted ${events.length} events`);
}

function insertEventDocumentLinks(db: any, events: SampleEvent[]): void {
  console.log('🔗 Creating event-document links...');

  const insertStmt = db.prepare(`
    INSERT INTO event_documents (event_id, document_id, created_at)
    VALUES (?, ?, ?)
  `);

  let linkCount = 0;
  const insertMany = db.transaction((evts: SampleEvent[]) => {
    for (const event of evts) {
      if (event.linkedDocuments && event.linkedDocuments.length > 0) {
        for (const docId of event.linkedDocuments) {
          // Use current timestamp for created_at
          const now = new Date().toISOString();
          insertStmt.run(event.id, docId, now);
          linkCount++;
        }
      }
    }
  });

  insertMany(events);

  console.log(`✅ Created ${linkCount} event-document links`);
}

function main(): void {
  try {
    // Verify JSON exists
    if (!fs.existsSync(JSON_DATA_PATH)) {
      throw new Error(`Sample data JSON not found: ${JSON_DATA_PATH}`);
    }

    // Delete existing database if present
    if (fs.existsSync(OUTPUT_DB_PATH)) {
      fs.unlinkSync(OUTPUT_DB_PATH);
      console.log('🗑️  Removed old database');
    }

    // Create new database
    const db = new Database(OUTPUT_DB_PATH);

    // Enable foreign keys
    db.pragma('foreign_keys = ON');

    // Create schema
    createSchema(db);

    // Load JSON data
    console.log('📖 Reading sample data JSON...');
    const jsonData = fs.readFileSync(JSON_DATA_PATH, 'utf8');
    const sampleData: SampleData = JSON.parse(jsonData);
    console.log(`✅ Loaded data: ${sampleData.metadata.totalEvents} events, ${sampleData.metadata.totalDocuments} documents`);

    // Insert data
    insertDocuments(db, sampleData.documents);
    insertEvents(db, sampleData.timelineEvents);
    insertEventDocumentLinks(db, sampleData.timelineEvents);

    // Verify counts
    const docCount = db.prepare('SELECT COUNT(*) as count FROM documents').get() as { count: number };
    const eventCount = db.prepare('SELECT COUNT(*) as count FROM timeline_events').get() as { count: number };
    const linkCount = db.prepare('SELECT COUNT(*) as count FROM event_documents').get() as { count: number };

    console.log('\n📊 Database statistics:');
    console.log(`   Documents: ${docCount.count}`);
    console.log(`   Events: ${eventCount.count}`);
    console.log(`   Links: ${linkCount.count}`);

    // Close database
    db.close();

    console.log('\n✅ Sample database created successfully!');
    console.log(`📦 Location: ${OUTPUT_DB_PATH}`);
    console.log(`💾 Size: ${(fs.statSync(OUTPUT_DB_PATH).size / 1024).toFixed(1)} KB`);

  } catch (error) {
    console.error('❌ Error building database:', error);
    process.exit(1);
  }
}

// Run
main();
