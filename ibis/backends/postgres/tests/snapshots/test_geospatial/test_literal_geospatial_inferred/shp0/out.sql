SELECT
  ST_ASEWKB("t0"."<POINT (0 0)>") AS "<POINT (0 0)>"
FROM (
  SELECT
    ST_GEOMFROMTEXT('POINT (0 0)') AS "<POINT (0 0)>"
) AS "t0"