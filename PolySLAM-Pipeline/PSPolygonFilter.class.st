Class {
	#name : #PSPolygonFilter,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'inlier',
		'chains'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #initialization }
PSPolygonFilter >> initialize [
	super initialize.
	inlier := 0.05.
	chains := OrderedCollection new.
]

{ #category : #public }
PSPolygonFilter >> link: aList [
	|lhelper lut|
	aList withIndexDo: [ :e :i| e id: i. e visited: false ].
	lhelper := PSInflateLinkingProbability new.
	lhelper inlier:inlier.
	lut := PSAdjacencyMatrix fromLines: aList probabilityHelper: lhelper.
	"traversal the LUT table"
	
]

{ #category : #public }
PSPolygonFilter >> perform [
	|frontierFilter obstacleFilter|
	frontierFilter := PSFrontierFilter from: polygonA  and: polygonB.
	frontierFilter perform.
	obstacleFilter := PSObstacleFilter from: polygonA  and: polygonB.
	obstacleFilter perform.
	self link:  ((frontierFilter edges), (obstacleFilter edges))
]
