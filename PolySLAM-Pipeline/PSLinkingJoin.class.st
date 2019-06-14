Class {
	#name : #PSLinkingJoin,
	#superclass : #PSLinkingNode,
	#instVars : [
		'joins',
		'joinsId'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #querying }
PSLinkingJoin >> allChains [
	|chains collection|
	chains := OrderedCollection new.
	collection  := self joins collect: [ :e| e allChains ].
	collection do:[:list|
		list do:[:c| 
			c addFirst: self.
			chains add: c
		]	
	].
	^ chains
]

{ #category : #'instance creation' }
PSLinkingJoin >> from: aValue with: list [
	joinsId := list.
	nodeValue := aValue.
	nodeValue visited: true.
	connected := true.
	^ self
]

{ #category : #testing }
PSLinkingJoin >> getJoins [
	|node|
	joins := OrderedCollection new.
	joinsId do:[:id|
		node := self root lookDown: id.
		node ifNotNil: [
			node isConnected ifTrue:[joins add: node]]].
]

{ #category : #testing }
PSLinkingJoin >> isConnected [
	^ connected
]

{ #category : #testing }
PSLinkingJoin >> isJoin [
	^ true
]

{ #category : #accessing }
PSLinkingJoin >> joins [
	joins ifNil: [ self getJoins ].
	^ joins
]

{ #category : #accessing }
PSLinkingJoin >> joins: anObject [
	joins := anObject
]

{ #category : #querying }
PSLinkingJoin >> leave [
	^ {} asOrderedCollection 
]
