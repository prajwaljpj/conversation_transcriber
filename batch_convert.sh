decoding="nnet2"


wordstxt=graph/words.txt
decodeconfig=nnet_a_gpu_online/conf/online_nnet2_decoding.conf
beam=15.0
latticebeam=6.0
accousticscale=0.1
model=nnet_a_gpu_online/final.mdl
graph=graph/HCLG.fst

## for nnet3

mfcchires=
ivectorconf=
wordboundary=
