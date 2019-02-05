Extension { #name : #BlockClosure }

{ #category : #'*PolySLAM-Core' }
BlockClosure >> forkAt: priority andPrint: aBlock [
	| timeSpent semaphore |
	
	semaphore := Semaphore new.
	[[ timeSpent := self timeToRun. ] ensure: [semaphore signal].
		Transcript show: (aBlock cull: timeSpent totalSeconds asFloat asTimeString); cr.
	] forkAt: priority.

]
