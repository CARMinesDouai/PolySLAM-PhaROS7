Class {
	#name : #VMLineFitterDebug,
	#superclass : #VMLineFitterOld,
	#instVars : [
		'iterationCounter'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'as yet unclassified' }
VMLineFitterDebug >> createResultWithLine: line [
	| errors inlierChain refinedLine refinedErrors result refinementCounter lastIterationSize |
	
	Transcript
		show: '  initial line='; show: ((line angle) * 360 / Float twoPi) rounded printString;
		show: ' ('; show: sampleChain size printString; show: ')'.
	
	refinementCounter := 0.
	lastIterationSize := 0.
	inlierChain := sampleChain.
	refinedLine := line.
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
		Transcript
			show: ' ref. line='; show: ((refinedLine angle) * 360 / Float twoPi) rounded printString;
			show: ' ('; show: inlierChain size printString; show: ')'.
	].
	Transcript cr.
	
	result := VMLineFittingResult vectors: inlierChain errors: refinedErrors line: refinedLine.
	
	result lineHistory add: line.	"add the original 'unrefined' line. used for visualization only"
	
	^ result

]

{ #category : #'as yet unclassified' }
VMLineFitterDebug >> evaluateResults [
	super evaluateResults.
	Transcript show: 'results:'; cr.
	
	sortedResults do: [ :resultArray |
		Transcript
			show: '  size=';
			show: resultArray second vectorCollection size printString;
			show: ', score=';
			show: resultArray second score printString;
			cr.
		].
]

{ #category : #initialization }
VMLineFitterDebug >> initialize [
	super initialize.
	iterationCounter := 0.
]

{ #category : #loop }
VMLineFitterDebug >> iterateOnce: sampleSize [
	iterationCounter := iterationCounter + 1.
	Transcript
		show: 'loop iteration #';
		show: iterationCounter printString;
		show: ' (size=';
		show: sampleSize printString;
		show: ')';
		cr.
	super iterateOnce: sampleSize.
]
