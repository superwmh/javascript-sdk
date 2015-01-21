should = require 'should'

Clan = require('../src/Clan.coffee')('testgame-key', 'testgame-secret') # app credentials

dataset = require './0-dataset.json'

gamerCred = null

describe 'Gamer transactions', ->

	balance = null
	history = null

	tx = null

	it 'it should login first', (done)->
		Clan.login null , (err, gamer)->
			gamer.should.have.property('gamer_id')
			gamer.should.have.property('gamer_secret')
			tx = Clan.withGamer(gamer).transactions(Clan.privateDomain)
			done()

	it 'should call balance', (done)->
		tx.balance (err, aBalance)->
			if err? then return done(err)
			balance = aBalance
			done()

	it 'should call history', (done)->
		tx.history (err, aHistory)->
			if err? then return done(err)
			history = aHistory.history
			done()

	it 'should send a transaction', (done)->
		tx.create {Gold: 100}, 'jsclient test', (err, aBalance)->
			if err? then return done(err)
			aBalance.Gold.should.eql(100+(balance.Gold || 0))
			balance = aBalance
			done()

	it 'should reset Gold balance to 0', (done)->
		tx.create {Gold: -balance.Gold, Silver: 1}, 'jsclient test', (err, aBalance)->
			if err? then return done(err)
			aBalance.Gold.should.eql(0)
			done()

	it 'should report an error if trying to withdraw too much', (done)->
		tx.create {Gold: -1}, 'jsclient test', (err, aBalance)->
			err.status.should.eql(449)
			err.name.should.eql 'BalanceInsufficient'
			should(aBalance).be.undefined
			done()

	it 'should call history again', (done)->
		tx.history (err, aHistory)->
			if err? then return done(err)
			aHistory.history.length.should.eql(history.length+2)
			history = aHistory.history
			done()

	it 'should call history with unit param too', (done)->
		tx.history 'Silver', (err, aHistory)->
			if err? then return done(err)
			aHistory.history.length.should.be.lessThan(history.length)
			done()
