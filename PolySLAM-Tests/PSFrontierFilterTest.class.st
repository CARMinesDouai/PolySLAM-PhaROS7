Class {
	#name : #PSFrontierFilterTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSFrontierFilterTest >> testPerform [
	|c helper polygon collections pA pB |
	c := FLMaterializer materializeFromFileNamed: '/home/mrsang/kf-test.fuel'.
	pA := (VMVectorCollectionSimplifier compute: ((c at:9) polygon) inlierThreshold: 0.01 ) result.
	pB := (VMVectorCollectionSimplifier compute: ((c at:10) polygon) inlierThreshold: 0.01 ) result.
	{ pA. pB. } asRenderableElement inspect.
	
	helper := PSFrontierFilter  from: pA and: pB. 
	helper perform.
	"{helper polygonA. helper polygonB} asRenderableElement  inspect."
]
