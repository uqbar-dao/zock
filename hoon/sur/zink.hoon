|%
+$  child  *
+$  parent  *
+$  phash  @                     ::  Pedersen hash
+$  hash-req
  $%  [%cell head=phash tail=phash]
      [%atom val=@]
  ==
::
+$  hint
  $%  [%0 axis=@]
      [%1 res=phash]
      [%2 subf1=phash subf2=phash]
      ::  encodes to 
      ::   [3 subf-hash atom 0] if atom
      ::   [3 subf-hash 0 cell-hash cell-hash] if cell
      ::
      $:  %3 
          subf=phash 
          $=  subf-res
          $%  [%atom @]
              [%cell head=phash tail=phash]
          ==
      ==
      [%4 subf=phash atom=@]
      [%5 subf1=phash subf2=phash]
      [%6 subf1=phash subf2=phash subf3=phash]
      [%7 subf1=phash subf2=phash]
      [%8 subf1=phash subf2=phash]
      [%9 axis=@ subf1=phash leaf=phash path=(list phash)]
      [%10 axis=@ subf1=phash subf2=phash oldleaf=phash path=(list phash)]
      [%cons subf1=phash subf2=phash]
      ::  [%jet core-hash
  ==
:: subject -> formula -> hint
+$  hints  (map phash (map phash hint))
::  map of a noun's merkle children. root -> [left right]
+$  merk-tree  (map phash [phash phash])
:: subject -> axis -> int. cached number of nock 0 lookups
+$  zero-cache  (map phash (map @ud @ud))
:: same map but int -> subject -> axis for cairo's benefit
+$  reverse-zc  (map @ud (map phash @ud))
+$  zc-state  [zc=zero-cache rzc=reverse-zc num=@ud]
::
++  pre-comp
  %-  ~(gas by *(map * phash))
  :~  [0 2.089.986.280.348.253.421.170.679.821.480.865.132.823.066.470.938.446.095.505.822.317.253.594.081.284]
      [1 1.089.549.915.800.264.549.621.536.909.767.699.778.745.926.517.555.586.332.772.759.280.702.396.009.108]
      [2 1.637.368.371.864.026.355.245.122.316.446.106.576.874.611.007.407.245.016.652.355.316.950.184.561.542]
      [3 936.823.097.115.478.672.163.131.070.534.991.867.793.647.843.312.823.827.742.596.382.032.679.996.195]
      [4 469.486.474.782.544.164.430.568.959.439.120.883.383.782.181.399.389.907.385.047.779.197.726.806.430]
      [5 2.941.083.907.689.010.536.497.253.969.578.701.440.794.094.793.277.200.004.061.830.176.674.600.429.738]
      [6 2.741.690.337.285.522.037.147.443.857.948.052.150.995.543.108.052.651.970.979.313.688.522.374.979.162]
      [7 2.258.442.912.665.439.649.622.769.515.993.460.039.756.024.697.697.714.582.745.734.598.954.638.194.578]
      [8 2.743.794.648.056.839.147.566.190.792.738.700.325.779.538.550.063.233.531.691.573.479.295.033.948.774]
      [9 3.149.011.590.233.272.225.803.080.114.059.308.917.528.748.800.879.621.812.239.443.987.136.907.759.492]
      [10 2.466.881.358.002.133.364.822.637.278.001.945.633.159.199.669.109.451.817.445.969.730.922.553.850.042]
      [11 1.602.195.742.608.144.856.779.311.879.863.141.684.990.052.756.940.086.705.696.922.586.637.104.021.594]
      [12 108.289.613.193.197.664.273.020.636.632.286.985.109.898.695.751.875.754.699.753.665.839.093.823.971]
  ==
--
