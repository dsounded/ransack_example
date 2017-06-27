module Finder
  extend self

  def find
    ModelA.ransack(g: [{model_bs_id_eq: 1, model_bs_name_eq: 'b_1'}, {model_bs_id_eq: 2, model_bs_name_eq: 'b_12'}])

    # "SELECT \"model_as\".* FROM \"model_as\" LEFT OUTER JOIN \"model_bs\" ON \"model_bs\".\"model_a_id\" = \"model_as\".\"id\"
    #  WHERE ((\"model_bs\".\"id\" = 1 AND \"model_bs\".\"name\" = 'b_1') AND
    #        (\"model_bs\".\"id\" = 2 AND \"model_bs\".\"name\" = 'b_12'))"
    # above query won't get a result because of AND

    # But what I really need here are strict dependencies, which should say if model A has child records: one of them obey
    # rule `{model_bs_id_eq: 1, model_bs_name_eq: 'b_1'}` and another obey rule `{model_bs_id_eq: 2, model_bs_name_eq: 'b_12'}`
    # than I need this model A record

    # A.ransack(model_bs_id_in: [1, 2], model_bs_name_in: ["b_1", "b_2"]).result this won't work also
    # because it allows to find all the combination like:
    # 1) {model_bs_id_eq: 1, model_bs_name_eq: 'b_1'}
    # 2) {model_bs_id_eq: 2, model_bs_name_eq: 'b_12'}
    # 3) {model_bs_id_eq: 1, model_bs_name_eq: 'b_12'}
    # 4) {model_bs_id_eq: 2, model_bs_name_eq: 'b_1'}

    # This does not check existence of 2 conditions in the same time also
  end

  # Maybe some solution with subqueries could work ? For now I do it like
  def additional_queries_search
    result = ModelA.all

    [{model_bs_id_eq: 1, model_bs_name_eq: 'b_1'}, {model_bs_id_eq: 2, model_bs_name_eq: 'b_12'}].each do |condition1|
      result = result & ModelA.ransack(condition1).result(distinct: true)
    end

    # It does what I need but with power O(n):

    # SELECT DISTINCT "model_as".* FROM "model_as" LEFT OUTER JOIN "model_bs" ON "model_bs"."model_a_id" = "model_as"."id"
    # WHERE ("model_bs"."id" = 1 AND "model_bs"."name" = 'b_1')
    # SELECT DISTINCT "model_as".* FROM "model_as" LEFT OUTER JOIN "model_bs" ON "model_bs"."model_a_id" = "model_as"."id"
    # WHERE ("model_bs"."id" = 2 AND "model_bs"."name" = 'b_12')
    # and Union will do the stuff, any ideas ?
  end
end
