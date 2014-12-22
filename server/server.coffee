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
		whereFlg = true

		if req.query.Payload
			query = 'SELECT * FROM (
						SELECT ROW_NUMBER() OVER ( ORDER BY d.date ) AS RowNum, *
						FROM ( 
								(
									SELECT b.Id, b.Date, b.MessageId, b.ClientId, b.Destination as QueueName, b.ProcessingStatus, b.Payload
									FROM MessagingLog.dbo.ApplicationMessages a 
									LEFT JOIN MessagingLog.dbo.ActiveMQMessages b 
									ON a.MessageId = b.MessageId 
									WHERE a.Payload LIKE ' + '\'%' + req.query.Payload + '%\' 
								)
								UNION ALL 
								(
									SELECT Id, Date, MessageId, ClientId, QueueName, ProcessingStatus, Payload 
									FROM MessagingLog.dbo.ApplicationMessages 
									WHERE Payload LIKE ' + '\'%' + req.query.Payload + '%\' 
								)
							) d
						WHERE d.id IS NOT NULL '
		else
			query =	'SELECT * FROM (
						SELECT  ROW_NUMBER() OVER ( ORDER BY d.date ) AS RowNum, *
						FROM ( 
								(
									SELECT b.Id, b.Date, b.MessageId, b.ClientId, b.Destination as QueueName, b.ProcessingStatus, b.Payload
									FROM MessagingLog.dbo.ActiveMQMessages b
								)
								UNION ALL 
								(
									SELECT Id, Date, MessageId, ClientId, QueueName, ProcessingStatus, Payload 
									FROM MessagingLog.dbo.ApplicationMessages 
								)
							) d
						WHERE d.id IS NOT NULL '


		if req.query.MessageId
			query += ' AND b.MessageId like ' + '\'%' + req.query.MessageId + '%\''

		if req.query.Date
			query += ' AND b.Date > ' + '\'' + req.query.Date + '\''

		if req.query.ProcessingStatus
			query += ' AND b.ProcessingStatus like ' + '\'' + req.query.ProcessingStatus + '\''

		if req.query.QueueName
			query += ' AND b.QueueName like ' + '\'%' + req.query.QueueName + '%\''

		query += ') e '

		if req.query.offset
			start = parseInt(req.query.offset) + 1
			count = parseInt(req.query.count)
			finish = start + count
			query += ' WHERE RowNum >= ' + start + ' AND RowNum < ' + finish + ' ORDER BY RowNum'
		
		console.log query

		sql.query connectionString, query, (err, result) ->
			if err
				res.json "Query Failed \n" + err
			else
				res.json result
