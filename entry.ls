require! <[cheerio request minimist fs]>
argv = minimist process.argv.slice(2), {string: \_}

[id] = argv._

utf8proxy = process.env.UTF8PROXY_PORT ? 'localhost:5000'
utf8proxy -= // ^tcp:\/\/ //
console.log utf8proxy

err, response, body <- request "http://#{utf8proxy}/TIPO_DR/servlet/InitLogoPictureWordDetail?sKeyNO=#{id}"
#body = fs.readFileSync f, \utf-8
$ = cheerio.load body
var rowspan
rowprefix = ''

x = for i in $ 'tr'
  if rowspan
    if --rowspan == 0 => rowprefix := ''
  var prev
  foo = for x in $ i .find 'td'
    text = $ x .text! - /^\s+|\s+$/g
    if text isnt /商品類別/ and prev isnt /商品類別/
      if y = $ x .attr 'rowspan'
        rowspan = +y - 1
        rowprefix := $ x .text! - /^\s+|\s+$/g
        continue
    if text is '在案狀況'
      continue
    prev := text
    text
  res = []
  while [k, v]? = foo.splice 0, 2
    break unless k
    continue if k is /目前在案狀況/
    continue if rowprefix is /說明/
    if v is /、/
      v = v.split /、/ .map -> it - /^\s+|\s+$|。$/g
    res.push [rowprefix + k, v]
  res

res = {[k, v] for [k, v] in x.reduce (++)}
console.log res

return unless argv.insert

#err, response, img <- request "http://tmsearch.tipo.gov.tw/TIPO_DR/servlet/ShowPicture_Serv?apply_no=#{id}"
#console.log img.length
require! pgrest

conString = argv.db ? process.env.PGDATABASE
plx <- pgrest .new conString, {+client}

<- plx.upsert {
  collection: \trademarks
  q: 申請案號: "#id"
  $: $set: data: res
}, _, -> console.log \err it

console.log \done
return plx.end!
