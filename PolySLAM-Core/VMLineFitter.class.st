"
This class is fitting a line to a collection of vectors. This is done in an iterative manner for multiple subsets (all including the first vector in the provided collection).

Public API and Key Messages
	
	- compute: <Collection of Vectors> startVector: <Vector>
		public entry point. performs the line fitting process
		
	
Tuning parameters
	- in #loop the vaiable minSize can be changed to limit the size of the vector collections that are tested
	  for line fitting
	- VMLineFittingResult class' #score method can be changed to favor different line fittings
"
Class {
	#name : #VMLineFitter,
	#superclass : #Object,
	#instVars : [
		'input',
		'startVector',
		'sampleChain',
		'resultHistory',
		'sortedResults',
		'inlierThreshold',
		'loopStepFactor'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #public }
VMLineFitter class >> compute: aVectorCollection [ 
	^(self new)
		compute: aVectorCollection
]

{ #category : #public }
VMLineFitter class >> compute: aVectorCollection startVector: aVector [
	^(self new)
		compute: aVectorCollection startVector: aVector
]

{ #category : #public }
VMLineFitter >> compute: aVectorCollection [
	
	input := aVectorCollection.
	startVector := aVectorCollection first.
	self createSampleChain.
	self loop.
	self evaluateResults.
	

]

{ #category : #public }
VMLineFitter >> compute: aVectorCollection startVector: aVector [
	
	"Transcript show: self class printString; show: ' inlierThreshold='; show: inlierThreshold printString; cr."
	
	input := aVectorCollection.
	startVector := aVector.
	self createSampleChain.
	self loop.
	self evaluateResults.
	
	^ self result.
]

{ #category : #computing }
VMLineFitter >> computeInlierChain: errorCollection [
	"returns a collection of chained vectors that have an error less than 'inlierThreshold'"
	| inlierChain |
	
	inlierChain := sampleChain species new.
	
	errorCollection doWithIndex: [ :e :i |
		e > inlierThreshold ifTrue: [
			inlierChain ifEmpty: [ inlierChain add: sampleChain first ].
			^inlierChain
		].
		inlierChain add: (sampleChain at: i).
	].
	
	inlierChain ifEmpty: [ inlierChain add: sampleChain first ].

	^inlierChain
]

{ #category : #computing }
VMLineFitter >> computeInlierChain: errorCollection withChain: vectorChain [
	"returns a collection of chained vectors that have an error less than 'inlierThreshold'"
	| inlierChain |
	
	inlierChain := vectorChain species new.
	
	errorCollection doWithIndex: [ :e :i |
		e > inlierThreshold ifTrue: [
			inlierChain ifEmpty: [ inlierChain add: vectorChain first ].
			^inlierChain
		].
		inlierChain add: (vectorChain at: i).
	].
	
	inlierChain ifEmpty: [ inlierChain add: vectorChain first ].

	^inlierChain
]

{ #category : #computing }
VMLineFitter >> createResultWithLine: line [
	| errors inlierChain refinedLine refinedErrors result refinementCounter lastIterationSize |
	
	refinementCounter := 0.
	inlierChain := sampleChain.
	refinedLine := line.
	lastIterationSize := 0.
	
	"refinement loop"
	[ (refinementCounter < 20) and: [lastIterationSize ~= inlierChain size] ] whileTrue: [
		refinementCounter := refinementCounter + 1.
		lastIterationSize := inlierChain size.
		"compute square errors for the current line"
		errors := (VMLineFittingErrorComputer compute: inlierChain line: refinedLine) errorCollection.
		inlierChain := self computeInlierChain: errors.
		refinedLine := VMLinearRegression compute: inlierChain.
		refinedErrors := (VMLineFittingErrorComputer compute: sampleChain line: refinedLine) errorCollection.
		inlierChain := self computeInlierChain: refinedErrors.
	].
	
	result := VMLineFittingResult vectors: inlierChain errors: refinedErrors line: refinedLine.
	
	result lineHistory add: line.	"add the original 'unrefined' line. used for visualization only"
	
	^ result

]

{ #category : #computing }
VMLineFitter >> createSampleChain [
	"creates a vector chain that contains vectors that are connected to the start vector and
	share the same type (e.g. only obstacles, or only frontiers)"
	| offset |
	offset := input indexOf: startVector.
	sampleChain := VMVectorChain new.
	
	sampleChain add: startVector.
	
	1 to: input size - 1 do: [ :index |
		| vec |
		vec := input atWrap: index + offset.
		vec pointA = sampleChain last pointB ifFalse: [ ^self ].
		vec type = startVector type ifFalse: [ ^self ].
		sampleChain add: vec.
	]
]

{ #category : #computing }
VMLineFitter >> evaluateResults [
	| index resultCollection |
	
	index := 0.
	resultCollection := resultHistory collect: [ :result | index := index + 1. {index.  result.  result score} ].
	sortedResults := resultCollection copy sort: [ :a :b | a last > b last ].
	"note: the best result (according to the score) is 'sortedResults first'."
	

]

{ #category : #computing }
VMLineFitter >> fittingResult: line chain: vectorChain [
	"creates an inlier chain that only contains vectors from 'vectorChain' (instead of 'sampleChain')
	and creates a VMLineFittingResult instance from that."
	| errorCollection truncatedChain result |
	
	errorCollection := (VMLineFittingErrorComputer compute: vectorChain line: line) errorCollection.
	truncatedChain := self computeInlierChain: errorCollection withChain: vectorChain.
	result := VMLineFittingResult vectors: truncatedChain errors: errorCollection line: line.
	
	^ result
]

{ #category : #initialization }
VMLineFitter >> initialize [
	resultHistory := OrderedCollection new.
	inlierThreshold := 0.02 squared. "square distance"
	loopStepFactor := 0.5.

]

{ #category : #accessing }
VMLineFitter >> inlierThreshold [
	^ inlierThreshold
]

{ #category : #accessing }
VMLineFitter >> inlierThreshold: aNumber [
	inlierThreshold := aNumber.
]

{ #category : #loop }
VMLineFitter >> iterateOnce: initialSize [
	| line activeChain truncatedResult fullResult refinementCounter sampleSize |
	
	sampleSize := initialSize.
	refinementCounter := 0.
	[ refinementCounter < 4 ] whileTrue: [
		refinementCounter := refinementCounter + 1.
		activeChain := sampleChain collect: [:v|v] from: 1 to: sampleSize.
		line := VMLinearRegression compute: activeChain.
		truncatedResult := self fittingResult: line chain: activeChain.
		resultHistory add: truncatedResult.
		fullResult := self fittingResult: line chain: sampleChain.
		resultHistory add: fullResult.
		sampleSize := fullResult vectorCollection size.
	].

]

{ #category : #loop }
VMLineFitter >> loop [
	"loop over the different start sizes of the vector chains"
	| size |
	
	size := sampleChain size.
	
	self iterateOnce: size.
	size := (size * loopStepFactor) floor.
	
	[ size > 3 ] whileTrue: [
		self iterateOnce: size.
		size := (size * loopStepFactor) floor.
	]

]

{ #category : #accessing }
VMLineFitter >> loopStepFactor [
	^ loopStepFactor
]

{ #category : #accessing }
VMLineFitter >> loopStepFactor: aFloat [
	((aFloat >= 0) or: [aFloat <= 0]) ifTrue: [ ^ self error: 'invalid loopStepFactor. must lie in the interval (0, 1)' ].
	loopStepFactor := aFloat.
]

{ #category : #accessing }
VMLineFitter >> result [
	^ sortedResults
		first "top scoring triplet"
			second "the actual result (first is the iteration index, third is the score)"
]

{ #category : #accessing }
VMLineFitter >> resultHistory [
	^resultHistory
]
