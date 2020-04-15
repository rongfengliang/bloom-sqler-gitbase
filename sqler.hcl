codecounts {
    exec = <<SQL
SELECT
	repo,
	MONTH,
	YEAR,
	DAY,
	sum( JSON_EXTRACT( info, '$.Code.Additions' ) AS code_lines_added ) AS code_lines_addeds,
	sum( JSON_EXTRACT( info, '$.Code.Deletions' ) AS code_lines_removed ) AS code_lines_removeds 
FROM
	(
	SELECT
		repository_id AS repo,
		commit_stats ( repository_id, commit_hash ) AS info,
		commits.commit_author_when AS commit_when,
		YEAR ( committer_when ) AS YEAR,
		MONTH ( committer_when ) AS MONTH,
		DAY ( committer_when ) AS DAY 
	FROM
		ref_commits
		NATURAL JOIN commits 
	) a 
GROUP BY
	repo,
	YEAR,
	MONTH,
    DAY
ORDER BY
	MONTH,
	YEAR,
	DAY;
SQL
}

cache {
    cron = "* 1 * * *"
    trigger {
        webhook = "http://lb/codecounts"
    }
}

apps {
   exec = <<SQL
     select 1
   SQL
}
