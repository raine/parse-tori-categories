require! <[ fs acorn acorn/dist/walk archy ]>
require! ramda: {map, create-map-entry, merge-all, merge, filter, where-eq, pipe, tap, to-string, take}
require! treis

is-category-list = (node-type, node) ->
    node.kind is \var and
    node.declarations?.0.id.name is \category_list

find-category-list-props = (ast) ->
    walk.find-node-at ast, null, null, is-category-list
    |> (.node.declarations.0.init.properties)

prop-to-obj  = -> (it.key.value): it.value.value
props-to-obj = (map prop-to-obj) >> merge-all

get-simple-props = map ->
    props = props-to-obj it.value.properties
    merge id: it.key.value, props

category-list-to-tree = (list) ->
    root = 'CATEGORIES'
    recurse-category = (cat) ->
        label: cat?.'name_en' or root
        nodes: map recurse-category, filter do
            where-eq do
                level  : cat?.level + 1 or 0
                parent : cat?.id or void
            , list
    recurse-category null

# :: FilePath -> [Object]
parse = pipe do
    fs.read-file-sync
    acorn.parse
    find-category-list-props
    get-simple-props

render = category-list-to-tree >> archy

parse-and-render = parse >> render
parse-and-render 'arrays_v2.js'
|> console.log 
