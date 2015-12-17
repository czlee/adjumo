\a
\f ,
\o adjudicators.csv
select adjud_id, adjud_name, ranking, univ_name, univ_code, region_name from adjudicator left join university on adjudicator.univ_id = university.univ_id left join region on region.region_id = adjudicator.region_id;
\o teams.csv
select speaker_id, speaker.team_id, speaker_name, speaker_esl, team_code, univ_name, univ_code from speaker left join team on speaker.team_id = team.team_id left join university on university.univ_id = team.univ_id;
\o institutions.csv
select univ_id, univ_name, univ_code from university