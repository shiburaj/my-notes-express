require('dotenv').config();

const mysql = require("mysql2");

const dbName = process.env.DB_DATABASE || "notes";

// First connect WITHOUT database to create it
const db = mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASS || "",
});

// Connect to MySQL
db.connect((err) => {
    if (err) {
      console.error('Database connection failed:', err);
      return;
    }
    console.log('Connected to MySQL');

    // Step 1: Create Database if not exists
    db.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``, (err) => {
      if (err) {
        console.error('Error creating database:', err);
        db.end();
        return;
      }
      console.log(`Database '${dbName}' is ready.`);

      // Step 2: Switch to the database
      db.query(`USE \`${dbName}\``, (err) => {
        if (err) {
          console.error('Error selecting database:', err);
          db.end();
          return;
        }

        // Step 3: Check if table exists
        const tableName = 'notes';
        const checkTableQuery = `SHOW TABLES LIKE '${tableName}'`;

        db.query(checkTableQuery, (err, results) => {
          if (err) {
            console.error('Error checking table:', err);
            db.end();
            return;
          }

          if (results.length > 0) {
            console.log(`Table '${tableName}' already exists.`);
            db.end();
          } else {
            console.log(`Table '${tableName}' does not exist. Creating...`);
            createTable(tableName);
          }
        });
      });
    });
  });
  
  // Function to Create Table
  function createTable(tableName) {
    const createTableQuery = `
      CREATE TABLE ${tableName} (
        id INT AUTO_INCREMENT PRIMARY KEY,
        content TEXT NOT NULL
      )
    `;
  
    db.query(createTableQuery, (err, result) => {
      if (err) {
        console.error('Error creating table:', err);
        return;
      }
      console.log('Table created successfully.');
      db.end();
    });
  }