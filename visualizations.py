import psycopg2
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

#config
#set visual style
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (10,6)

#Db connection details
DB_CONFIG = {
    'dbname': os.getenv('ST_DB', 'spaceship_titanic'),
    'user': os.getenv('ST_USER', 'postgres'),
    'password': os.getenv('ST_PASS', ''),
    'host': os.getenv('ST_HOST', 'localhost'),
    'port': int(os.getenv('ST_PORT', 5432))
}

#centralized chart configurations
CHART_CONFIGS = [
    {
        'name': 'Cryosleep Impact',
        'query': 'SELECT * FROM mv_cryosleep_impact',
        'x_col': 'status',
        'y_col': 'pct_transported',
        'colors': ['#3498db', '#e74c3c', '#95a5a6'],
        'filename': 'cryosleep_impact.png',
        'xlabel': 'Status'
    },
    {
        'name': 'Home Planet',
        'query': 'SELECT * FROM mv_transport_by_planet WHERE homeplanet IS NOT NULL',
        'x_col': 'homeplanet',
        'y_col': 'pct_transported',
        'colors': ['#2ecc71', '#f39c12', '#9b59b6'],
        'filename': 'planet_transport.png',
        'xlabel': 'Home Planet'
    },
    {
        'name': 'Deck Analysis',
        'query': 'SELECT * FROM mv_deck_analysis',
        'x_col': 'deck',
        'y_col': 'pct_transported',
        'colors': 'steelblue',
        'filename': 'deck_analysis.png',
        'xlabel': 'Deck',
        'figsize': (12, 6)
    },
    {
        'name': 'Age Demographics',
        'query': '''SELECT * FROM mv_age_transport ORDER BY CASE age_bucket
                    WHEN '0-11' THEN 1
                    WHEN '12-17' THEN 2
                    WHEN '18-29' THEN 3
                    WHEN '30-49' THEN 4
                    WHEN '50+' THEN 5
                    ELSE 6 END''',
        'x_col': 'age_bucket',
        'y_col': 'pct_transported',
        'colors': 'coral',
        'filename': 'age_demographics.png',
        'xlabel': 'Age Group',
        'figsize': (12, 6)
    },
    {
        'name': 'Spending Analysis',
        'query': '''SELECT 
                        CASE
                            WHEN total_spend IS NULL THEN 'Unknown'
                            WHEN total_spend = 0 THEN 'No spend'
                            WHEN total_spend < 500 THEN 'Low (<$500)'
                            WHEN total_spend < 2000 THEN 'Medium ($500-2k)'
                            ELSE 'High ($2k+)'
                        END AS spend_category,
                        COUNT(*) AS n,
                        ROUND(100.0*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/COUNT(*), 1) AS pct_transported
                    FROM spaceship_titanic
                    GROUP BY 1''',
        'x_col': 'spend_category',
        'y_col': 'pct_transported',
        'colors': 'purple',
        'filename': 'spending_analysis.png',
        'xlabel': 'Spending Category',
        'figsize': (12, 6),
        'alpha': 0.7,
        'rotation': 15,
        'sort_order': ['No spend', 'Low (<$500)', 'Medium ($500-2k)', 'High ($2k+)', 'Unknown']
    },
    {
        'name': 'CryoSleep Adoption by Homeplanet',
        'query': '''SELECT
                        homeplanet, COUNT(*) AS total,
                        SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END) AS cryosleep_count,
                        ROUND(100.0*SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END)/COUNT(*), 1) AS cryosleep_rate
                    FROM spaceship_titanic
                    WHERE homeplanet IS NOT NULL AND cryosleep IS NOT NULL
                    GROUP BY homeplanet
                    ORDER BY cryosleep_rate DESC''',
        'x_col': 'homeplanet',
        'y_col': 'cryosleep_rate',
        'colors': ['#16a085', '#d35400', '#8e44ad'],
        'filename': 'cryosleep_by_homeplanet.png',
        'xlabel': 'Home Planet',
        'ylabel': 'Cryosleep Adpotion Rate (%)',
        'chart_type': 'correlation'
    },
    {
        'name': 'Cryosleep distribution by Deck',
        'query': '''SELECT
                        deck, COUNT(*) AS total,
                        SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END) AS cryosleep_count,
                        ROUND(100.0*SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END)/COUNT(*), 1) AS cryosleep_rate
                    FROM spaceship_titanic
                    WHERE deck IS NOT NULL AND cryosleep IS NOT NULL
                    GROUP BY deck
                    ORDER BY deck''',
        'x_col': 'deck',
        'y_col': 'cryosleep_rate',
        'colors': '#27ae60',
        'filename': 'cryosleep_by_deck.png',
        'xlabel':'Deck',
        'ylabel': 'Cryosleep Rate (%)',
        'chart_type': 'correlation'
    },
    {
        'name': 'Port vs Starboard',
        'query': '''SELECT
                        side, COUNT(*) AS n,
                        SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
                        ROUND(100.0*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/COUNT(*), 1) AS pct_transported
                    FROM spaceship_titanic
                    WHERE side IS NOT NULL
                    GROUP BY side
                    ORDER BY side''',
        'x_col': 'side',
        'y_col': 'pct_transported',
        'colors': ['#e67e22', '#3498db'],
        'filename': 'side_transport.png',
        'xlabel': 'Cabin Side',
        'ylabel': 'Transportation Rate (%)'
    },
    {
        'name': 'Destination Analysis',
        'query': '''SELECT
                        destination, COUNT(*) AS n,
                        SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
                        ROUND(100.0*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/COUNT(*), 1) AS pct_transported
                    FROM spaceship_titanic
                    WHERE destination IS NOT NULL
                    GROUP BY destination
                    ORDER BY pct_transported DESC''',
        'x_col': 'destination',
        'y_col': 'pct_transported',
        'colors': ['#1abc9c', '#e74c3c', '#34495e'],
        'filename': 'destination_transport.png',
        'xlabel': 'Destination',
        'ylabel': 'Transportation Rate (%)'
    }
]

def create_bar_chart(df, config, output_dir):
    """
    Creates a standardized bar chart from dataframe and config
    """

    figsize = config.get('figsize', (10,6))
    colors = config.get('colors', 'steelblue')
    alpha = config.get('alpha', 1.0)
    rotation = config.get('rotation', 0)
    ylabel = config.get('ylabel', 'Transportation Rate (%)')
    chart_type = config.get('chart_type', 'normal')

    plt.figure(figsize=figsize)

    bars = plt.bar(df[config['x_col']], df[config['y_col']], color=colors, alpha=alpha)

    if chart_type == 'correlation':
        plt.title(f"{config['name']}", fontsize=18, fontweight='bold', pad=20)
    else:
        plt.title(f"Transportation Rate by {config['name']}", fontsize=18,fontweight='bold', pad=20)

    plt.xlabel(config['xlabel'], fontsize=14, fontweight='bold')
    plt.ylabel(ylabel, fontsize=14, fontweight='bold')

    if rotation > 0:
        plt.xticks(rotation=rotation, ha='right', fontsize=12)

    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width() / 2., height + 2,
                 f'{height:.1f}%', ha='center', va='bottom',
                 fontweight='bold', fontsize=11)

    plt.tight_layout()
    output_path = output_dir / config['filename']
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"Saved: {output_path}")
    plt.close()

def main():
    output_dir = Path('images')
    output_dir.mkdir(exist_ok=True)

    # connect to db
    print("🔌 Connecting to PostgreSQL...")
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("Connected successfully!\n")
    except psycopg2.Error as e:
        print(f"Connection failed: {e}")
        return

    try:
        for config in CHART_CONFIGS:
            print(f"📊 Creating {config['name']} chart...")

            df = pd.read_sql(config['query'], conn)
            df = df.dropna(subset=[config['x_col']])

            if 'sort_order' in config:
                df[config['x_col']] = pd.Categorical(
                    df[config['x_col']],
                    categories=config['sort_order'],
                    ordered=True
                )
                df = df.sort_values(config['x_col'])

            print(df)
            print()

            create_bar_chart(df, config, output_dir)
            print()

        print("=" * 70)
        print("✅ ALL VISUALIZATIONS CREATED SUCCESSFULLY!")
        print("=" * 70)
        print(f"\n📁 Check your '{output_dir}/' folder for {len(CHART_CONFIGS)} PNG files:")
        for i, config in enumerate(CHART_CONFIGS, 1):
            print(f"   {i}. {config['filename']}")

    except Exception as e:
        print(f"❌ Error during chart generation: {e}")
        import traceback
        traceback.print_exc()

    finally:
        conn.close()
        print("\n🔌 Database connection closed.")

if __name__ == "__main__":
    main()