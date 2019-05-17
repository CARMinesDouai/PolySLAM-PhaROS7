Class {
	#name : #PSLinkingProbabilityTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSLinkingProbabilityTest >> getPatternFrom: l1 and: l2 [
	| collection angle baseline |

	collection := OrderedCollection new.
	0 to:6 do:[:i|
		angle := (Float pi)*i/ 6.0.
		collection add: (PSLinkedEdge
			from: ( (l1 * (angle cos) ) @ (l1 * (angle sin) ) )
			to: ( (l2 * (angle cos) ) @ (l2 * (angle sin) ) )
			type: 2)
	].
	baseline := collection removeLast reversed.
	collection := collection reversed.
	^ baseline -> collection 
]

{ #category : #tests }
PSLinkingProbabilityTest >> testNearestVertices [
	|p l1 l2 vs|
	l1 := PSLinkedEdge from: 2@1 to: 5@2  type:1.
	l2 := PSLinkedEdge from: 5@4 to: 6@7  type:1.
	p := PSLinkingProbability from: l1 and: l2. 
	vs := p nearestVertices.
	self assert: vs first = l1 value pointB.
	self assert: vs second = l2 value pointA.
	
	l1 := PSLinkedEdge from: 1@1 to: 3@3  type:1.
	l2 := PSLinkedEdge from: 4@4 to: 7@7  type:1.
	p := PSLinkingProbability from: l1 and: l2. 
	vs := p nearestVertices.
	self assert: vs first = l1 value pointB.
	self assert: vs second = l2 value pointA.
]

{ #category : #tests }
PSLinkingProbabilityTest >> testPattern [
	|pattern  score graph color data|
	
	pattern := {self getPatternFrom: 0.2 and: 1.4. self getPatternFrom: 0.1 and: 1.3.}.
	
	score := pattern collect:[ :p|
		p value collect: [ :e| (p value indexOf: e) ->   (PSLinkingProbability from: p key and: e) probability  ]
	].
		
	graph  := RTGrapher new.
	color := Array with: Color blue with: Color red.
score
	withIndexDo: [ :arg1 :arg2 | 
		| tmp6 |
		tmp6 := color at: arg2.
		data := RTData new.
		data
			label: tmp6;
			connectColor: (tmp6 alpha: 0.5).
		data dotShape ellipse color: (tmp6 alpha: 0.5).
		data
			points: arg1;
			x: #key;
			y: #value.
		data interaction
			noInteractions.
		graph add: data ].
graph inspect
]

{ #category : #tests }
PSLinkingProbabilityTest >> testProbability [
	|l1 l2 p|
	l1 := PSLinkedEdge from: 1@1 to: 3@3  type:1 chain:1. 
	l2 := PSLinkedEdge from: 3@3 to: 5@7  type:1 chain:2.
	p := PSLinkingProbability from: l1 and: l2.
	self assert: p probability = 1.
	l2 := PSLinkedEdge from: 6@1 to: 4@3  type:1 chain:2.
	p := PSLinkingProbability from: l1 and: l2.
	self assert: p probability > 0.
	l2 := PSLinkedEdge from: -1@1 to: -2@4  type:1 chain:2.
	p := PSLinkingProbability from: l1 and: l2.
	self assert: p probability < 0.2.
	l2 := PSLinkedEdge from: 4@4 to: 7@7  type:1 chain: 2.
	p := PSLinkingProbability from: l1 and: l2.
	self assert: p probability = 0.24659696394160652.
	l2 := PSLinkedEdge from: 2@1.7 to: 5@4  type:1 chain: 2.
	p := PSLinkingProbability from: l1 and: l2.
	{ l1. l2 } asRenderableElement inspect.
	p probability inspect.
]

{ #category : #tests }
PSLinkingProbabilityTest >> testSpecialCase [
	|l1 l2 p|
	l1 := PSLinkedEdge from: 2@1 to: 4@3  type:1 chain:1. 
	l2 := PSLinkedEdge from: 2@1 to: 7@6  type:1 chain:2.
	p := PSInflateColinearProbability from: l1 and: l2.
	{ l1. l2 } asRenderableElement inspect.
	p probability inspect.
]
