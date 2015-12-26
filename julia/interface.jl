function calculateDebateScores(paramater, teams, adjs)

   regionalRepresentation = paramater * 0.25
   genderRepresentation = teams * 0.5
   languageRepresentation = adjs * 1

   return regionalRepresentation, genderRepresentation, languageRepresentation
end
