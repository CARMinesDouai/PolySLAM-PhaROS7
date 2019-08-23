Class {
	#name : #PSIntersectionFilterTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSIntersectionFilterTest >> testPerform [
	|c helper polygon collections pA pB |
	c := FLMaterializer materializeFromFileNamed: '/home/mrsang/kf-test.fuel'.
	pA := (VMVectorCollectionSimplifier compute: ((c at:19) polygon) inlierThreshold: 0.01 ) result.
	pB := (VMVectorCollectionSimplifier compute: ((c at:20) polygon) inlierThreshold: 0.01 ) result.
	{ pA. pB. } asRenderableElement inspect.
	
	helper := PSIntersectionFilter  from: pA and: pB. 
	helper perform.
	"{helper polygonA. helper polygonB} asRenderableElement  inspect."
]
