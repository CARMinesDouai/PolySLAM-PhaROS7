Class {
	#name : #VMRansac,
	#superclass : #Object,
	#instVars : [
		'input',
		'vectorDictionary',
		'inlier',
		'outlier',
		'ignored',
		'model',
		'squareError',
		'threshold',
		'refinedModel',
		'finalErrors',
		'result'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'rendering support' }
VMRansac class >> rendererClass [
	^VMRansacRenderer
]

{ #category : #converting }
VMRansac >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #temp }
VMRansac >> collectFrom: startVector UpTo: endVector ifReachedDo: reachedBlock [
	| currentVector |
]

{ #category : #'computation - errors' }
VMRansac >> computeErrorForLine: aLine [
	inlier := OrderedCollection new.
	outlier := OrderedCollection new.
	ignored := OrderedCollection new.
	
	result line: aLine.
	result vectorCollection removeAll.
	result errorCollection removeAll.
	
	input do: [ :vec |
		vec type isObstacle
			ifTrue: [
				| errorValue |
				errorValue := self computeErrorVec: vec model: aLine.
			
				errorValue < threshold ifTrue: [
					inlier add: vec.
					result vectorCollection add: vec.
					result errorCollection add: errorValue.
					squareError := squareError + errorValue.
			] ifFalse: [
				outlier add: vec.
			].
		] ifFalse: [
			"vectors of type 'frontier' or 'sector' are not processed and stored in 'ignored'."
			ignored add: vec.
		].
	].

	inlier ifEmpty: [
		threshold := threshold * 2.
		^ self computeErrorForLine: aLine
	].
]

{ #category : #computation }
VMRansac >> computeErrorVec: aVector model: aLine [
	^(aLine squareDistanceToPoint: aVector pointA) +
		(aLine squareDistanceToPoint: aVector pointB)
]

{ #category : #'computation - model refinement' }
VMRansac >> computeErrors: vectorChain model: line [
	^(VMLineFittingErrorComputer compute: vectorChain line: line) errorCollection

]

{ #category : #public }
VMRansac >> computeForInput: aVectorCollection [
	"ransac run with samples choosen from 'aVectorCollection'"
	
	"first pass: determine inliers and compute error"
	self input: aVectorCollection.
	model := self createLineFromSamples: self drawSamples.
	self computeErrorForLine: model.
	
	"second pass: reject bad inlier use linear regression on remaining inliers"
	self refine: inlier model: model.
	self computeErrorForLine: refinedModel.
]

{ #category : #public }
VMRansac >> computeForInput: aVectorCollection withSamplesFrom: aCollection [
	"ransac run with samples choosen from 'aCollection'."
	
	"first pass: determine inliers and compute error"
	self input: aVectorCollection.
	model := self createLineFromSamples: (self drawSamplesFrom: aCollection).
	self computeErrorForLine: model.
	
	"second pass: reject bad inlier use linear regression on remaining inliers"
	self refine: inlier model: model.
	self computeErrorForLine: refinedModel.
]

{ #category : #computation }
VMRansac >> computeVectorChains: vectorCollection [
	| chains currentChain index |
	
	chains := OrderedCollection new.
	index := 1.
	
	[ index <= vectorCollection size ] whileTrue: [
		currentChain := OrderedCollection new.
		currentChain add: (vectorCollection at: index).
		chains add: currentChain.
		index := index + 1.
		
		[ (index <= vectorCollection size) and: [ currentChain last pointB = ((vectorCollection at: index) pointA) ] ] whileTrue: [
			currentChain add: (vectorCollection at: index).
			index := index + 1.
		].
	].
	
	^chains
	
]

{ #category : #temp }
VMRansac >> connectChains: vectorCollection [
	| newChains nextChainIndex |
	
	newChains := OrderedCollection new.
	nextChainIndex := 2.
	
	newChains add: vectorCollection first.
	
	[ nextChainIndex <= vectorCollection size ] whileTrue: [
		| prevLast nextFirst |
		"try to connect the previous chain with the following chain"
		prevLast := newChains last last.
		nextFirst := (vectorCollection at: nextChainIndex) first.
		self collectFrom: prevLast UpTo: nextFirst ifReachedDo: [].
	].
	
	^newChains

]

{ #category : #computation }
VMRansac >> createLineFromSamples: samples [
	^VMLine
		pointA: (samples first pointA)
		pointB:(samples last pointB)
]

{ #category : #computation }
VMRansac >> createVectorChains: vectorCollection [
	"creates a collection of 'chains'. a chain in this context is a collection of consecutive vectors"
	| chains |
	
	chains := OrderedCollection new.
	chains add: OrderedCollection new.
	chains last add: vectorCollection first.
	
	vectorCollection allButFirstDo: [ :vec |
		chains last last pointB = vec pointA
			ifFalse: [ chains add: OrderedCollection new ].
		chains last add: vec.
	].
	
	^chains

]

{ #category : #'computation - sampling' }
VMRansac >> drawSamples [
	"draws two random samples and returns them as an ordered collection"
	| rand size index samples |
	rand := Random new.
	size := input size.
	samples := OrderedCollection new.
	
	index := rand nextInt: size.
	samples add: (input at: index).
	
	index := index + (rand nextInt: (size - 1)).
	samples add: (input atWrap: index).
	
	^samples
	
	
]

{ #category : #'computation - sampling' }
VMRansac >> drawSamplesFrom: aCollection [
	"draws two random samples from the provided collection and returns them as an ordered collection"
	| rand size index samples |
	rand := Random new.
	size := aCollection size.
	samples := OrderedCollection new.
	
	index := rand nextInt: size.
	samples add: (aCollection at: index).
	
	index := index + (rand nextInt: (size - 1)).
	samples add: (aCollection atWrap: index).
	
	^samples
	
	
]

{ #category : #'GT Inspector' }
VMRansac >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	"composite inspectOnce."
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]

{ #category : #accessing }
VMRansac >> ignored [
	^ignored
]

{ #category : #initialization }
VMRansac >> initialize [
	input := nil.
	model := nil.
	threshold := 0.025.
	inlier := OrderedCollection new.
	outlier := OrderedCollection new.
	ignored := OrderedCollection new.
	squareError := 0.0.
	result := VMLineFittingResult new.

]

{ #category : #accessing }
VMRansac >> inlier [
	^inlier
]

{ #category : #accessing }
VMRansac >> input [
	^input
]

{ #category : #accessing }
VMRansac >> input: aVectorCollection [

	input := aVectorCollection.
	
	vectorDictionary := Dictionary new.
	input do: [ :vec |
		vectorDictionary at: vec pointA put: vec
	].
]

{ #category : #'as yet unclassified' }
VMRansac >> medianRefinedError [
	| errors |
	errors := self computeErrors: inlier model: refinedModel.
	errors sort.
	^errors middle.
	
]

{ #category : #accessing }
VMRansac >> model [
	^model
]

{ #category : #accessing }
VMRansac >> outlier [
	^outlier
]

{ #category : #'as yet unclassified' }
VMRansac >> plot [
	| cmd process data crlf medianError |
	cmd := 'gnuplot -p'.
	data := self printErrors2.
	medianError := self medianRefinedError.
	crlf := Character cr asString, Character lf asString.
	
	process := OSSUnixSubprocess new
		shellCommand: cmd;
		redirectStdin;
		redirectStdout;
		run.
	
	process stdinStream
		nextPutAll: 'plot ''-'' using 1:2 with points, "" using 1:2 with lines';
		nextPutAll: crlf;
		nextPutAll: data;
		nextPutAll: 'e', crlf;
		nextPutAll: '0 ', medianError printString, crlf;
		nextPutAll: inlier size printString, ' ', medianError printString, crlf;
		nextPutAll: 'e', crlf;
		close.	
	"1 halt."
	
	process waitForExit.
	process closeAndCleanStreams.
	

]

{ #category : #'as yet unclassified' }
VMRansac >> plot2 [
	| cmd process data |
	cmd := 'gnuplot -p -e "plot ''-'' with points"'.
	data := self printErrors2.
	
	process := OSSUnixSubprocess new
		shellCommand: cmd;
		redirectStdin;
		redirectStdout;
		run.
	
	process stdinStream
		nextPutAll: data;
		close.	
	"1 halt."
	
	process waitForExit.
	process closeAndCleanStreams.
	

]

{ #category : #converting }
VMRansac >> printErrors [
	| string errors |
	
	string := ''.
	
	errors := self computeErrors: inlier model: model.
	errors doWithIndex: [ :e :i |
		string := string, i printString, ' ', e printString, Character cr asString, Character lf asString.
	].
	
	^string
	
]

{ #category : #'as yet unclassified' }
VMRansac >> printErrors2 [
	| string errors |
	
	string := ''.
	
	errors := self computeErrors: inlier model: refinedModel.
	errors doWithIndex: [ :e :i |
		string := string, i printString, ' ', e printString, Character cr asString, Character lf asString.
	].
	
	^string
	
]

{ #category : #printing }
VMRansac >> printString [
	^self class name,
		' inlier size=', inlier size printString,
		', squareError=', squareError printString,
		', score=', self score printString.
]

{ #category : #'computation - model refinement' }
VMRansac >> refine: vectorCollection model: line [
	"refined the model by rejecting vectors with a large error and then
	run linear regression on the remaining data."
	| chains truncatedChains newCollection linearReg |
	
	chains := self createVectorChains: vectorCollection.
	truncatedChains := chains collect: [ :vectorChain | self truncateChain: vectorChain model: line ].
	newCollection := OrderedCollection new.
	truncatedChains do: [ :vectorChain | newCollection addAll: vectorChain ].
	
	linearReg := VMLinearRegression new.
	refinedModel := linearReg compute: newCollection.

]

{ #category : #accessing }
VMRansac >> refinedModel [
	^refinedModel
]

{ #category : #accessing }
VMRansac >> result [
	^result
]

{ #category : #accessing }
VMRansac >> score [
	inlier ifEmpty: [ ^ 0 ].
	
	^( (inlier size + 20 / 20) - 1 ) / squareError
]

{ #category : #accessing }
VMRansac >> squareError [
	^squareError.
]

{ #category : #accessing }
VMRansac >> threshold [
	^threshold
]

{ #category : #accessing }
VMRansac >> threshold: aNumber [
	threshold := aNumber
]

{ #category : #'computation - model refinement' }
VMRansac >> truncateChain: vectorChain model: line [
	"removes elements from the start/end of the chain if the error is significantly
	larger there compared to the rest of chain. for this we compute the 'cutoffThreshold'
	by setting so that 80% of the vectors have a smaller or equal error.
	
	note, that this does not necessarily mean that 20% of the vectors are removed. this
	only happens all of the larges 20% error vectors are located there."
	| errors errorsSorted cutoffThreshold newChain startIndex stopIndex |
	
	vectorChain ifEmpty: [ ^vectorChain ].
	errors := self computeErrors: vectorChain model: line.
	errorsSorted := errors copy sort.
	
	cutoffThreshold := errorsSorted at: (errorsSorted size * 0.8) ceiling.
	
	startIndex := 1.
	[(errors at: startIndex) >= cutoffThreshold] whileTrue: [ startIndex := startIndex + 1. startIndex > errors size ifTrue: [ ^vectorChain ] ].
	stopIndex := errors size.
	[(errors at: stopIndex) >= cutoffThreshold] whileTrue: [ stopIndex := stopIndex - 1 ].
	
	newChain := vectorChain species new.
	startIndex to: stopIndex do: [ :index |
		newChain add: (vectorChain at: index).
	].
	
	^newChain

]
