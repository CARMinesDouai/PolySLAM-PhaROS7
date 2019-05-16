Class {
	#name : #VMLineFitterOld,
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
VMLineFitterOld class >> compute: aVectorCollection [ 
	^(self new)
		compute: aVectorCollection
]

{ #category : #public }
VMLineFitterOld class >> compute: aVectorCollection startVector: aVector [
	^(self new)
		compute: aVectorCollection startVector: aVector
]

{ #category : #public }
VMLineFitterOld >> compute: aVectorCollection [
	
	input := aVectorCollection.
	startVector := aVectorCollection first.
	self createSampleChain.
	self loop.
	self evaluateResults.
	

]

{ #category : #public }
VMLineFitterOld >> compute: aVectorCollection startVector: aVector [
	
	"Transcript show: self class printString; show: ' inlierThreshold='; show: inlierThreshold printString; cr."
	
	input := aVectorCollection.
	startVector := aVector.
	self createSampleChain.
	self loop.
	self evaluateResults.
	
	^ self result.
]

{ #category : #'as yet unclassified' }
VMLineFitterOld >> computeInlierChain: errorCollection [
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

{ #category : #'as yet unclassified' }
VMLineFitterOld >> createResultWithLine: line [
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

{ #category : #'as yet unclassified' }
VMLineFitterOld >> createSampleChain [
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

{ #category : #'as yet unclassified' }
VMLineFitterOld >> evaluateResults [
	| index resultCollection |
	
	index := 0.
	resultCollection := resultHistory collect: [ :result | index := index + 1. {index.  result.  result score} ].
	sortedResults := resultCollection copy sort: [ :a :b | a last > b last ].
	"note: the best result (according to the score) is 'sortedResults first'."
	

]

{ #category : #initialization }
VMLineFitterOld >> initialize [
	resultHistory := OrderedCollection new.
	inlierThreshold := 0.02 squared. "square distance"
	loopStepFactor := 0.5.
]

{ #category : #accessing }
VMLineFitterOld >> inlierThreshold [
	^ inlierThreshold
]

{ #category : #accessing }
VMLineFitterOld >> inlierThreshold: aNumber [
	inlierThreshold := aNumber.
]

{ #category : #loop }
VMLineFitterOld >> iterateOnce: sampleSize [
	| line |
	"Transcript show: self class printString; show: ' iterateOnce'; show: ' sampleSize='; show: sampleSize printString; cr."
	line := VMLinearRegression compute: (sampleChain collect: [:v|v] from: 1 to: sampleSize).
	resultHistory add: (self createResultWithLine: line).

]

{ #category : #loop }
VMLineFitterOld >> loop [
	| size minSize |
	
	size := sampleChain size.
	minSize := 3.
	
	"one 'loop iteration' outside of the loop to ensure that we always have at least one result
	in 'resultHistory'."
	self iterateOnce: size.
	size := (size * loopStepFactor) floor.
		
	[ size > minSize ] whileTrue: [
		self iterateOnce: size.
		size := (size * loopStepFactor) floor.
	].
	
	"1 halt."
]

{ #category : #accessing }
VMLineFitterOld >> loopStepFactor [
	^ loopStepFactor
]

{ #category : #accessing }
VMLineFitterOld >> loopStepFactor: aFloat [
	((aFloat >= 0) or: [aFloat <= 0]) ifTrue: [ ^ self error: 'invalid loopStepFactor. must lie in the interval (0, 1)' ].
	loopStepFactor := aFloat.
]

{ #category : #accessing }
VMLineFitterOld >> result [
	^ sortedResults
		first "top scoring triplet"
			second "the actual result (first is the iteration index, third is the score)"
]

{ #category : #accessing }
VMLineFitterOld >> resultHistory [
	^resultHistory
]
