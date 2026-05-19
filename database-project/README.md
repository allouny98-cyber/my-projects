# Database Design Project

## Overview
Relational database design and analysis for a video games catalog. 
The project covers schema design, table creation, relationships between entities, and SQL queries for analytical insights.

## Objectives
- Design a normalized relational schema for a video games catalog
- Define primary keys, foreign keys and relationships between tables
- Write SQL queries to extract insights about games, developers, and platforms

## Tools & Technologies
- SQL Server
- T-SQL

## Database Tables
- `Games` — main games catalog with title, release year, Metascore, price
- `Developers` — game development studios and countries
- `Genres` — game categories
- `Platforms` — platforms and manufacturers
- `GamePlatforms` — bridge table linking games to platforms

## Files
- `database_project.sql` — full SQL script (schema creation + queries)

## Key Analyses
1. Games performance by genre and platform
2. Developer productivity and quality (Metascore)
3. Price trends across platforms and years

## Author
Yoni Alloun — [allouny98@gmail.com](mailto:allouny98@gmail.com)
