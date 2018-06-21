REM p4 archive -h -D archive //depot/EpicBranch/.../*.dll
REM p4 archive -h -D archive //depot/EpicBranch/.../*.exe
REM p4 archive -h -D archive //depot/EpicBranch/.../*.pdb
set DateRange=2016/7/19
p4 archive -h -D archive //depot/UnrealEngine4/.../*.pdb@2000/01/01,%DateRange%
p4 archive -h -D archive //depot/UnrealEngine4/.../*.exe@2000/01/01,%DateRange%
p4 archive -h -D archive //depot/UnrealEngine4/.../*.dll@2000/01/01,%DateRange%
p4 archive -h -D archive //depot/SourceAssets/.../*.ZTL@2000/01/01,%DateRange%
p4 archive -h -D archive //depot/SourceAssets/.../*.ma@2000/01/01,%DateRange%
p4 archive -h -D archive //depot/SourceAssets/.../*.fbx@2000/01/01,%DateRange%
