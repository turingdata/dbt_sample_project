## Source Medium Test Project

#### Data Layers
1. upstream_source (raw data and testing)
2. staging (apply hard rules of casting, creating business keys, renaming)
3. core (dimensional layer)
4. mart (can create sub-mart folders specific to : business  / region )
5. biz (final layer used for analytics)