  # Python / Jupyter Data Analysis

## Overview
Exploratory data analysis on a video games catalog stored in SQL Server. 
The notebook connects to the database, retrieves the data, and uses Python/Pandas 
to clean, transform, and visualize insights about games, developers, and platforms.

## Objectives
- Connect Python to a SQL Server database using SQLAlchemy
- Extract data from multiple joined tables (Games, Developers, Genres, Platforms)
- Perform exploratory data analysis (EDA) on game ratings, prices, and trends
- Build visualizations to communicate insights clearly

## Tools & Libraries
- Python 3.x
- Jupyter Notebook
- Pandas — data manipulation
- NumPy — numerical operations
- Matplotlib & Seaborn — data visualization
- SQLAlchemy + PyODBC — SQL Server connection

## Data Source
- Local SQL Server database: `VideoGamesDB`
- Connected via Windows Authentication
- Tables joined: Games, Developers, Genres, Platforms, GamePlatforms

## Files
- `YONI_ALLOUN_.ipynb` — main analysis notebook (all outputs included)

## Key Findings
The notebook explores several questions, including:
1. Distribution of games by genre and platform
2. Top developers by quality (Metascore) and quantity
3. Price trends across platforms and release years
4. Relationships between price, quality, and platform manufacturer

*(All charts and outputs are saved inside the notebook — viewable directly on GitHub.)*

## How to Run
This notebook connects to a **local SQL Server database** (`VideoGamesDB`).
To reproduce the analysis, you would need to:
1. Set up a SQL Server instance with the `VideoGamesDB` database
2. Update the `server_name` variable in the connection cell
3. Run all cells

**Note:** All outputs (charts, tables) are already saved in the notebook, 
so you can view the full analysis without running the code.

## Author
Yoni Allouche — [allouny98@gmail.com](mailto:allouny98@gmail.com)
