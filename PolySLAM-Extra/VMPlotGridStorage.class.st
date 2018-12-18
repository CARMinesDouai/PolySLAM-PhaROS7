Class {
	#name : #VMPlotGridStorage,
	#superclass : #VMPlotObject,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMPlotGridStorage >> plotFrontiers: aCollection [
	self plotVectorCollection: aCollection color: Color green.

]

{ #category : #accessing }
VMPlotGridStorage >> plotObstacles: aCollection [
	self plotVectorCollection: aCollection color: Color black.

]

{ #category : #plotting }
VMPlotGridStorage >> plotParent: parent [
	| frontiers sectors obstacles |
	super plotParent: parent.
	
	frontiers := OrderedCollection new.
	sectors := OrderedCollection new.
	obstacles := OrderedCollection new.
	
	model do: [ :cell |
		cell do: [ :polygon |
			self plotFilledPolygon: polygon.
			polygon do: [ :vector |
				vector isFrontier ifTrue: [ frontiers add: vector ].
				vector isObstacle ifTrue: [ obstacles add: vector ].
				vector isSector ifTrue: [ sectors add: vector ]. ]. ]. ].
	self plotSectors: sectors.
	self plotFrontiers: frontiers.
	self plotObstacles: obstacles.

]

{ #category : #accessing }
VMPlotGridStorage >> plotSectors: aCollection [
	self plotVectorCollection: aCollection color: (Color r:0.95 g:0.85 b:0).

]
