module.exports = (app, options) ->
	sql = require 'node-sqlserver-unofficial'
	getConnectionString = require "./conn"
	connectionString = getConnectionString()
	query = ''
	whereFlg = false
	addWhere = () ->
		if whereFlg
			query = query + ' AND '
		else 
			query = query + ' WHERE '
			whereFlg = true


	app.get '/api/log', (req, res) -> 
		whereFlg = false
		query =	'SELECT  *
					FROM ( 
						SELECT ROW_NUMBER() OVER ( ORDER BY b.id ) AS RowNum, 
							b.id, b.activemq_id, b.date_time, b.destination, 
							b.message_text, b.sender_id, b.servicetracker_id, b.origin, b.status
				        FROM Messages' 

		if req.query.servicetracker_id
			query = query + ' a RIGHT JOIN Messages b ON a.activemq_id = b.activemq_id WHERE a.servicetracker_id like ' + '\'%' + req.query.servicetracker_id + '%\'' 
			whereFlg = true
		else 
			query = query + ' b'

		if req.query.activemq_id
			addWhere()
			query = query + ' b.activemq_id like ' + '\'%' + req.query.activemq_id + '%\''

		if req.query.message_text
			addWhere()
			query = query + ' b.message_text like ' + '\'%' + req.query.message_text + '%\''

		if req.query.date_time
			addWhere()
			query = query + ' b.date_time > ' + '\'' + req.query.date_time + '\''

		if req.query.status
			addWhere()
			query = query + ' b.status like ' + '\'' + req.query.status + '\''

		if req.query.destination
			addWhere()
			query = query + ' b.destination like ' + '\'%' + req.query.destination + '%\''

		query = query + ') as c'

		if req.query.offset
			start = parseInt(req.query.offset)
			count = parseInt(req.query.count)
			finish = start + count
			query = query + ' WHERE RowNum >= ' + start + ' AND RowNum < ' + finish + ' ORDER BY RowNum'

		console.log query

		sql.query connectionString, query, (err, result) ->
			if err
				res.json {response: "Query Failed \n" + err}
			else
				res.json {response: result}


	###
	app.get '/api/destinations', (req, res) ->
		client.query "select destination, sum(CASE WHEN status = 1 THEN 1 ELSE 0 END) as send, sum(CASE WHEN status = 2 THEN 1 ELSE 0 END) as get from messages group by destination", (err, result) ->
			if err
				res.json err
			else if result and result.rows
				res.json result.rows

	app.get '/api/messages', (req, res) ->
		dest = req.query.destination
		console.log dest
		client.query "select text, sum(CASE WHEN status = 1 THEN 1 ELSE 0 END) as send, sum(CASE WHEN status = 2 THEN 1 ELSE 0 END) as get from messages where destination = $1 group by text", [dest], (err, result) ->
			if err
				res.json err
			else if result and result.rows
				res.json result.rows
	###