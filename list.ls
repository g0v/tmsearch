require! <[cheerio minimist fs]>
argv = minimist process.argv.slice 2

[f] = argv._

body = fs.readFileSync f, \utf-8
$ = cheerio.load body
[meta, header, ...res] = for i in $ 'tr'
	for x in $ i .find 'td'
		$ x .text! - /^\s+|\s+$/g

res = res.map ->
	{[k, it[i]] for k, i in header}

res.=filter -> it.序號
console.log JSON.stringify res
