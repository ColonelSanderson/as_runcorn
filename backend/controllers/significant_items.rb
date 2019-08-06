class ArchivesSpaceService < Sinatra::Base
  Endpoint.get('/repositories/:repo_id/significant_items/:level')
    .description("Get significant item lists")
    .params(["repo_id", :repo_id],
            ["level", String, "Significance level (or 'all')"],
            ["series", [String], "URIs of series", :optional => true])
    .permissions([])
    .returns([200, '[:physical_representation]']) \
  do
    json_response(SignificantItems.list(params))
  end
end
