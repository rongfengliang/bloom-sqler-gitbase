codecounts {
    exec = <<SQL
	SET inmemory_joins = 1;
	SET SQL_SELECT_LIMIT=200;
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
	DAY
	limit 500;
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
	  SET SQL_SELECT_LIMIT=200; 
      SET inmemory_joins = 1;
     select 1;
   SQL
}

repos {
exec = <<SQL
SET SQL_SELECT_LIMIT=500; 
SELECT
    repository_id,
    LANGUAGE(file_path, blob_content) as lang,
    SUM(JSON_EXTRACT(LOC(file_path, blob_content), '$.Code')) as code,
    SUM(JSON_EXTRACT(LOC(file_path, blob_content), '$.Comment')) as comments,
    SUM(JSON_EXTRACT(LOC(file_path, blob_content), '$.Blank')) as blanks,
    COUNT(1) as files
FROM refs
NATURAL JOIN commit_files
NATURAL JOIN blobs
WHERE ref_name='HEAD'
GROUP BY lang,repository_id;
SQL
}