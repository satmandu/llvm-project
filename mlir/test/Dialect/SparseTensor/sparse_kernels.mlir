// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// RUN: mlir-opt %s \
// RUN: --linalg-generalize-named-ops --linalg-fuse-elementwise-ops \
// RUN: --sparsification | FileCheck %s

#SparseVector = #sparse_tensor.encoding<{ dimLevelType = [ "compressed" ] }>

#DCSR = #sparse_tensor.encoding<{ dimLevelType = [ "compressed", "compressed" ] }>

// CHECK-LABEL:   func @matmul1(
// CHECK-SAME:      %[[VAL_0:.*]]: tensor<10x20xf32, #sparse_tensor.encoding<{{{.*}}}>>,
// CHECK-SAME:      %[[VAL_1:.*]]: tensor<20x30xf32>,
// CHECK-SAME:      %[[VAL_2:.*]]: tensor<10x30xf32>) -> tensor<10x30xf32> {
// CHECK-DAG:       %[[VAL_3:.*]] = arith.constant 0 : index
// CHECK-DAG:       %[[VAL_4:.*]] = arith.constant 1 : index
// CHECK-DAG:       %[[VAL_5:.*]] = arith.constant 30 : index
// CHECK-DAG:       %[[VAL_6:.*]] = sparse_tensor.pointers %[[VAL_0]] {dimension = 0 : index} : tensor<10x20xf32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_7:.*]] = sparse_tensor.indices %[[VAL_0]] {dimension = 0 : index} : tensor<10x20xf32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_8:.*]] = sparse_tensor.pointers %[[VAL_0]] {dimension = 1 : index} : tensor<10x20xf32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_9:.*]] = sparse_tensor.indices %[[VAL_0]] {dimension = 1 : index} : tensor<10x20xf32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_10:.*]] = sparse_tensor.values %[[VAL_0]] : tensor<10x20xf32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_11:.*]] = bufferization.to_memref %[[VAL_1]] : memref<20x30xf32>
// CHECK-DAG:       %[[VAL_13:.*]] = bufferization.to_memref %[[VAL_2]] : memref<10x30xf32>
// CHECK:           %[[VAL_14:.*]] = memref.load %[[VAL_6]]{{\[}}%[[VAL_3]]] : memref<?xindex>
// CHECK:           %[[VAL_15:.*]] = memref.load %[[VAL_6]]{{\[}}%[[VAL_4]]] : memref<?xindex>
// CHECK:           scf.for %[[VAL_16:.*]] = %[[VAL_14]] to %[[VAL_15]] step %[[VAL_4]] {
// CHECK:             %[[VAL_17:.*]] = memref.load %[[VAL_7]]{{\[}}%[[VAL_16]]] : memref<?xindex>
// CHECK:             %[[VAL_18:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_16]]] : memref<?xindex>
// CHECK:             %[[VAL_19:.*]] = arith.addi %[[VAL_16]], %[[VAL_4]] : index
// CHECK:             %[[VAL_20:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_19]]] : memref<?xindex>
// CHECK:             scf.for %[[VAL_21:.*]] = %[[VAL_18]] to %[[VAL_20]] step %[[VAL_4]] {
// CHECK:               %[[VAL_22:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_21]]] : memref<?xindex>
// CHECK:               %[[VAL_23:.*]] = memref.load %[[VAL_10]]{{\[}}%[[VAL_21]]] : memref<?xf32>
// CHECK:               scf.for %[[VAL_24:.*]] = %[[VAL_3]] to %[[VAL_5]] step %[[VAL_4]] {
// CHECK:                 %[[VAL_25:.*]] = memref.load %[[VAL_13]]{{\[}}%[[VAL_17]], %[[VAL_24]]] : memref<10x30xf32>
// CHECK:                 %[[VAL_26:.*]] = memref.load %[[VAL_11]]{{\[}}%[[VAL_22]], %[[VAL_24]]] : memref<20x30xf32>
// CHECK:                 %[[VAL_27:.*]] = arith.mulf %[[VAL_23]], %[[VAL_26]] : f32
// CHECK:                 %[[VAL_28:.*]] = arith.addf %[[VAL_25]], %[[VAL_27]] : f32
// CHECK:                 memref.store %[[VAL_28]], %[[VAL_13]]{{\[}}%[[VAL_17]], %[[VAL_24]]] : memref<10x30xf32>
// CHECK:               }
// CHECK:             }
// CHECK:           }
// CHECK:           %[[VAL_29:.*]] = bufferization.to_tensor %[[VAL_13]] : memref<10x30xf32>
// CHECK:           return %[[VAL_29]] : tensor<10x30xf32>
// CHECK:         }
func.func @matmul1(%a: tensor<10x20xf32, #DCSR>,
              %b: tensor<20x30xf32>,
              %c: tensor<10x30xf32>) -> tensor<10x30xf32> {
  %0 = linalg.matmul
    ins(%a, %b: tensor<10x20xf32, #DCSR>, tensor<20x30xf32>)
    outs(%c: tensor<10x30xf32>) -> tensor<10x30xf32>
  return %0 : tensor<10x30xf32>
}

//
// Computes C = A x B with all matrices sparse (SpMSpM) in DCSR.
//
// CHECK-LABEL:   func @matmul2(
// CHECK-SAME:      %[[VAL_0:.*]]: tensor<4x8xf64, #sparse_tensor.encoding<{{{.*}}}>>,
// CHECK-SAME:      %[[VAL_1:.*]]: tensor<8x4xf64, #sparse_tensor.encoding<{{{.*}}}>> {
// CHECK-DAG:       %[[VAL_3:.*]] = arith.constant 0 : index
// CHECK-DAG:       %[[VAL_4:.*]] = arith.constant 1 : index
// CHECK-DAG:       %[[VAL_5:.*]] = arith.constant 2 : index
// CHECK-DAG:       %[[VAL_6:.*]] = arith.constant false
// CHECK-DAG:       %[[VAL_7:.*]] = arith.constant true
// CHECK:           %[[VAL_8:.*]] = bufferization.alloc_tensor() : tensor<4x4xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:           %[[VAL_9:.*]] = sparse_tensor.pointers %[[VAL_0]] {dimension = 0 : index} : tensor<4x8xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_10:.*]] = sparse_tensor.indices %[[VAL_0]] {dimension = 0 : index} : tensor<4x8xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_11:.*]] = sparse_tensor.pointers %[[VAL_0]] {dimension = 1 : index} : tensor<4x8xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_12:.*]] = sparse_tensor.indices %[[VAL_0]] {dimension = 1 : index} : tensor<4x8xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_13:.*]] = sparse_tensor.values %[[VAL_0]] : tensor<4x8xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xf64>
// CHECK:           %[[VAL_14:.*]] = sparse_tensor.pointers %[[VAL_1]] {dimension = 0 : index} : tensor<8x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_15:.*]] = sparse_tensor.indices %[[VAL_1]] {dimension = 0 : index} : tensor<8x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_16:.*]] = sparse_tensor.pointers %[[VAL_1]] {dimension = 1 : index} : tensor<8x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_17:.*]] = sparse_tensor.indices %[[VAL_1]] {dimension = 1 : index} : tensor<8x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK:           %[[VAL_18:.*]] = sparse_tensor.values %[[VAL_1]] : tensor<8x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xf64>
// CHECK:           %[[VAL_19:.*]] = memref.alloca(%[[VAL_5]]) : memref<?xindex>
// CHECK:           %[[VAL_20:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_3]]] : memref<?xindex>
// CHECK:           %[[VAL_21:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_4]]] : memref<?xindex>
// CHECK:           scf.for %[[VAL_22:.*]] = %[[VAL_20]] to %[[VAL_21]] step %[[VAL_4]] {
// CHECK:             %[[VAL_23:.*]] = memref.load %[[VAL_10]]{{\[}}%[[VAL_22]]] : memref<?xindex>
// CHECK:             memref.store %[[VAL_23]], %[[VAL_19]]{{\[}}%[[VAL_3]]] : memref<?xindex>
// CHECK:             %[[VAL_24:.*]], %[[VAL_25:.*]], %[[VAL_26:.*]], %[[VAL_27:.*]] = sparse_tensor.expand %[[VAL_8]] : tensor<4x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xf64>, memref<?xi1>, memref<?xindex>, index
// CHECK:             %[[VAL_28:.*]] = memref.load %[[VAL_11]]{{\[}}%[[VAL_22]]] : memref<?xindex>
// CHECK:             %[[VAL_29:.*]] = arith.addi %[[VAL_22]], %[[VAL_4]] : index
// CHECK:             %[[VAL_30:.*]] = memref.load %[[VAL_11]]{{\[}}%[[VAL_29]]] : memref<?xindex>
// CHECK:             %[[VAL_31:.*]] = memref.load %[[VAL_14]]{{\[}}%[[VAL_3]]] : memref<?xindex>
// CHECK:             %[[VAL_32:.*]] = memref.load %[[VAL_14]]{{\[}}%[[VAL_4]]] : memref<?xindex>
// CHECK:             %[[VAL_33:.*]]:3 = scf.while (%[[VAL_34:.*]] = %[[VAL_28]], %[[VAL_35:.*]] = %[[VAL_31]], %[[VAL_36:.*]] = %[[VAL_27]]) : (index, index, index) -> (index, index, index) {
// CHECK:               %[[VAL_37:.*]] = arith.cmpi ult, %[[VAL_34]], %[[VAL_30]] : index
// CHECK:               %[[VAL_38:.*]] = arith.cmpi ult, %[[VAL_35]], %[[VAL_32]] : index
// CHECK:               %[[VAL_39:.*]] = arith.andi %[[VAL_37]], %[[VAL_38]] : i1
// CHECK:               scf.condition(%[[VAL_39]]) %[[VAL_34]], %[[VAL_35]], %[[VAL_36]] : index, index, index
// CHECK:             } do {
// CHECK:             ^bb0(%[[VAL_40:.*]]: index, %[[VAL_41:.*]]: index, %[[VAL_42:.*]]: index):
// CHECK:               %[[VAL_43:.*]] = memref.load %[[VAL_12]]{{\[}}%[[VAL_40]]] : memref<?xindex>
// CHECK:               %[[VAL_44:.*]] = memref.load %[[VAL_15]]{{\[}}%[[VAL_41]]] : memref<?xindex>
// CHECK:               %[[VAL_45:.*]] = arith.cmpi ult, %[[VAL_44]], %[[VAL_43]] : index
// CHECK:               %[[VAL_46:.*]] = arith.select %[[VAL_45]], %[[VAL_44]], %[[VAL_43]] : index
// CHECK:               %[[VAL_47:.*]] = arith.cmpi eq, %[[VAL_43]], %[[VAL_46]] : index
// CHECK:               %[[VAL_48:.*]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_46]] : index
// CHECK:               %[[VAL_49:.*]] = arith.andi %[[VAL_47]], %[[VAL_48]] : i1
// CHECK:               %[[VAL_50:.*]] = scf.if %[[VAL_49]] -> (index) {
// CHECK:                 %[[VAL_51:.*]] = memref.load %[[VAL_13]]{{\[}}%[[VAL_40]]] : memref<?xf64>
// CHECK:                 %[[VAL_52:.*]] = memref.load %[[VAL_16]]{{\[}}%[[VAL_41]]] : memref<?xindex>
// CHECK:                 %[[VAL_53:.*]] = arith.addi %[[VAL_41]], %[[VAL_4]] : index
// CHECK:                 %[[VAL_54:.*]] = memref.load %[[VAL_16]]{{\[}}%[[VAL_53]]] : memref<?xindex>
// CHECK:                 %[[VAL_55:.*]] = scf.for %[[VAL_56:.*]] = %[[VAL_52]] to %[[VAL_54]] step %[[VAL_4]] iter_args(%[[VAL_57:.*]] = %[[VAL_42]]) -> (index) {
// CHECK:                   %[[VAL_58:.*]] = memref.load %[[VAL_17]]{{\[}}%[[VAL_56]]] : memref<?xindex>
// CHECK:                   %[[VAL_59:.*]] = memref.load %[[VAL_24]]{{\[}}%[[VAL_58]]] : memref<?xf64>
// CHECK:                   %[[VAL_60:.*]] = memref.load %[[VAL_18]]{{\[}}%[[VAL_56]]] : memref<?xf64>
// CHECK:                   %[[VAL_61:.*]] = arith.mulf %[[VAL_51]], %[[VAL_60]] : f64
// CHECK:                   %[[VAL_62:.*]] = arith.addf %[[VAL_59]], %[[VAL_61]] : f64
// CHECK:                   %[[VAL_63:.*]] = memref.load %[[VAL_25]]{{\[}}%[[VAL_58]]] : memref<?xi1>
// CHECK:                   %[[VAL_64:.*]] = arith.cmpi eq, %[[VAL_63]], %[[VAL_6]] : i1
// CHECK:                   %[[VAL_65:.*]] = scf.if %[[VAL_64]] -> (index) {
// CHECK:                     memref.store %[[VAL_7]], %[[VAL_25]]{{\[}}%[[VAL_58]]] : memref<?xi1>
// CHECK:                     memref.store %[[VAL_58]], %[[VAL_26]]{{\[}}%[[VAL_57]]] : memref<?xindex>
// CHECK:                     %[[VAL_66:.*]] = arith.addi %[[VAL_57]], %[[VAL_4]] : index
// CHECK:                     scf.yield %[[VAL_66]] : index
// CHECK:                   } else {
// CHECK:                     scf.yield %[[VAL_57]] : index
// CHECK:                   }
// CHECK:                   memref.store %[[VAL_62]], %[[VAL_24]]{{\[}}%[[VAL_58]]] : memref<?xf64>
// CHECK:                   scf.yield %[[VAL_67:.*]] : index
// CHECK:                 }
// CHECK:                 scf.yield %[[VAL_68:.*]] : index
// CHECK:               } else {
// CHECK:                 scf.yield %[[VAL_42]] : index
// CHECK:               }
// CHECK:               %[[VAL_69:.*]] = arith.cmpi eq, %[[VAL_43]], %[[VAL_46]] : index
// CHECK:               %[[VAL_70:.*]] = arith.addi %[[VAL_40]], %[[VAL_4]] : index
// CHECK:               %[[VAL_71:.*]] = arith.select %[[VAL_69]], %[[VAL_70]], %[[VAL_40]] : index
// CHECK:               %[[VAL_72:.*]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_46]] : index
// CHECK:               %[[VAL_73:.*]] = arith.addi %[[VAL_41]], %[[VAL_4]] : index
// CHECK:               %[[VAL_74:.*]] = arith.select %[[VAL_72]], %[[VAL_73]], %[[VAL_41]] : index
// CHECK:               scf.yield %[[VAL_71]], %[[VAL_74]], %[[VAL_75:.*]] : index, index, index
// CHECK:             }
// CHECK:             sparse_tensor.compress %[[VAL_8]], %[[VAL_19]], %[[VAL_24]], %[[VAL_25]], %[[VAL_26]], %[[VAL_76:.*]]#2 : tensor<4x4xf64, #sparse_tensor.encoding<{{{.*}}}>>, memref<?xindex>, memref<?xf64>, memref<?xi1>, memref<?xindex>, index
// CHECK:           }
// CHECK:           %[[VAL_77:.*]] = sparse_tensor.load %[[VAL_8]] hasInserts : tensor<4x4xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:           return %[[VAL_77]] : tensor<4x4xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:         }
func.func @matmul2(%A: tensor<4x8xf64, #DCSR>,
              %B: tensor<8x4xf64, #DCSR>) -> tensor<4x4xf64, #DCSR> {
  %c4 = arith.constant 4 : index
  %C = bufferization.alloc_tensor() : tensor<4x4xf64, #DCSR>
  %D = linalg.matmul
    ins(%A, %B: tensor<4x8xf64, #DCSR>, tensor<8x4xf64, #DCSR>)
       outs(%C: tensor<4x4xf64, #DCSR>) -> tensor<4x4xf64, #DCSR>
  return %D: tensor<4x4xf64, #DCSR>
}

// CHECK-LABEL:   func @conv2d(
// CHECK-SAME:      %[[VAL_0:.*]]: tensor<8x8xi32>,
// CHECK-SAME:      %[[VAL_1:.*]]: tensor<3x3xi32, #sparse_tensor.encoding<{{{.*}}}>>,
// CHECK-SAME:      %[[VAL_2:.*]]: tensor<6x6xi32>) -> tensor<6x6xi32> {
// CHECK-DAG:       %[[VAL_3:.*]] = arith.constant 0 : index
// CHECK-DAG:       %[[VAL_4:.*]] = arith.constant 1 : index
// CHECK-DAG:       %[[VAL_5:.*]] = arith.constant 6 : index
// CHECK-DAG:       %[[VAL_6:.*]] = bufferization.to_memref %[[VAL_0]] : memref<8x8xi32>
// CHECK-DAG:       %[[VAL_7:.*]] = sparse_tensor.pointers %[[VAL_1]] {dimension = 0 : index} : tensor<3x3xi32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_8:.*]] = sparse_tensor.indices %[[VAL_1]] {dimension = 0 : index} : tensor<3x3xi32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_9:.*]] = sparse_tensor.pointers %[[VAL_1]] {dimension = 1 : index} : tensor<3x3xi32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_10:.*]] = sparse_tensor.indices %[[VAL_1]] {dimension = 1 : index} : tensor<3x3xi32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_11:.*]] = sparse_tensor.values %[[VAL_1]] : tensor<3x3xi32, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_13:.*]] = bufferization.to_memref %[[VAL_2]] : memref<6x6xi32>
// CHECK:           %[[VAL_14:.*]] = memref.load %[[VAL_7]]{{\[}}%[[VAL_3]]] : memref<?xindex>
// CHECK:           %[[VAL_15:.*]] = memref.load %[[VAL_7]]{{\[}}%[[VAL_4]]] : memref<?xindex>
// CHECK:           scf.for %[[VAL_16:.*]] = %[[VAL_14]] to %[[VAL_15]] step %[[VAL_4]] {
// CHECK:             %[[VAL_17:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_16]]] : memref<?xindex>
// CHECK:             %[[VAL_18:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_16]]] : memref<?xindex>
// CHECK:             %[[VAL_19:.*]] = arith.addi %[[VAL_16]], %[[VAL_4]] : index
// CHECK:             %[[VAL_20:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_19]]] : memref<?xindex>
// CHECK:             scf.for %[[VAL_21:.*]] = %[[VAL_18]] to %[[VAL_20]] step %[[VAL_4]] {
// CHECK:               %[[VAL_22:.*]] = memref.load %[[VAL_10]]{{\[}}%[[VAL_21]]] : memref<?xindex>
// CHECK:               %[[VAL_23:.*]] = memref.load %[[VAL_11]]{{\[}}%[[VAL_21]]] : memref<?xi32>
// CHECK:               scf.for %[[VAL_24:.*]] = %[[VAL_3]] to %[[VAL_5]] step %[[VAL_4]] {
// CHECK:                 scf.for %[[VAL_25:.*]] = %[[VAL_3]] to %[[VAL_5]] step %[[VAL_4]] {
// CHECK:                   %[[VAL_26:.*]] = memref.load %[[VAL_13]]{{\[}}%[[VAL_25]], %[[VAL_24]]] : memref<6x6xi32>
// CHECK:                   %[[VAL_27:.*]] = arith.addi %[[VAL_25]], %[[VAL_17]] : index
// CHECK:                   %[[VAL_28:.*]] = arith.addi %[[VAL_24]], %[[VAL_22]] : index
// CHECK:                   %[[VAL_29:.*]] = memref.load %[[VAL_6]]{{\[}}%[[VAL_27]], %[[VAL_28]]] : memref<8x8xi32>
// CHECK:                   %[[VAL_30:.*]] = arith.muli %[[VAL_29]], %[[VAL_23]] : i32
// CHECK:                   %[[VAL_31:.*]] = arith.addi %[[VAL_26]], %[[VAL_30]] : i32
// CHECK:                   memref.store %[[VAL_31]], %[[VAL_13]]{{\[}}%[[VAL_25]], %[[VAL_24]]] : memref<6x6xi32>
// CHECK:                 }
// CHECK:               }
// CHECK:             }
// CHECK:           }
// CHECK:           %[[VAL_32:.*]] = bufferization.to_tensor %[[VAL_13]] : memref<6x6xi32>
// CHECK:           return %[[VAL_32]] : tensor<6x6xi32>
// CHECK:         }
func.func @conv2d(%input:  tensor<8x8xi32>,
             %filter: tensor<3x3xi32, #DCSR>,
             %output: tensor<6x6xi32>) -> tensor<6x6xi32> {
  %0 = linalg.conv_2d
    ins  (%input, %filter: tensor<8x8xi32>, tensor<3x3xi32, #DCSR>)
    outs (%output: tensor<6x6xi32>) -> tensor<6x6xi32>
  return %0 : tensor<6x6xi32>
}

// CHECK-LABEL:   func @quantized_matmul(
// CHECK-SAME:      %[[VAL_0:.*]]: tensor<5x3xi8>,
// CHECK-SAME:      %[[VAL_1:.*]]: tensor<3x6xi8, #sparse_tensor.encoding<{{{.*}}}>>,
// CHECK-SAME:      %[[VAL_2:.*]]: tensor<5x6xi64>) -> tensor<5x6xi64> {
// CHECK-DAG:       %[[VAL_3:.*]] = arith.constant 2 : i64
// CHECK-DAG:       %[[VAL_4:.*]] = arith.constant 0 : index
// CHECK-DAG:       %[[VAL_5:.*]] = arith.constant 1 : index
// CHECK-DAG:       %[[VAL_6:.*]] = arith.constant 5 : index
// CHECK-DAG:       %[[VAL_7:.*]] = bufferization.to_memref %[[VAL_0]] : memref<5x3xi8>
// CHECK-DAG:       %[[VAL_8:.*]] = sparse_tensor.pointers %[[VAL_1]] {dimension = 0 : index} : tensor<3x6xi8, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_9:.*]] = sparse_tensor.indices %[[VAL_1]] {dimension = 0 : index} : tensor<3x6xi8, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_10:.*]] = sparse_tensor.pointers %[[VAL_1]] {dimension = 1 : index} : tensor<3x6xi8, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_11:.*]] = sparse_tensor.indices %[[VAL_1]] {dimension = 1 : index} : tensor<3x6xi8, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_12:.*]] = sparse_tensor.values %[[VAL_1]] : tensor<3x6xi8, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_14:.*]] = bufferization.to_memref %[[VAL_2]] : memref<5x6xi64>
// CHECK:           %[[VAL_15:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_4]]] : memref<?xindex>
// CHECK:           %[[VAL_16:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_5]]] : memref<?xindex>
// CHECK:           scf.for %[[VAL_17:.*]] = %[[VAL_15]] to %[[VAL_16]] step %[[VAL_5]] {
// CHECK:             %[[VAL_18:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_17]]] : memref<?xindex>
// CHECK:             %[[VAL_19:.*]] = memref.load %[[VAL_10]]{{\[}}%[[VAL_17]]] : memref<?xindex>
// CHECK:             %[[VAL_20:.*]] = arith.addi %[[VAL_17]], %[[VAL_5]] : index
// CHECK:             %[[VAL_21:.*]] = memref.load %[[VAL_10]]{{\[}}%[[VAL_20]]] : memref<?xindex>
// CHECK:             scf.for %[[VAL_22:.*]] = %[[VAL_19]] to %[[VAL_21]] step %[[VAL_5]] {
// CHECK:               %[[VAL_23:.*]] = memref.load %[[VAL_11]]{{\[}}%[[VAL_22]]] : memref<?xindex>
// CHECK:               %[[VAL_24:.*]] = memref.load %[[VAL_12]]{{\[}}%[[VAL_22]]] : memref<?xi8>
// CHECK:               scf.for %[[VAL_25:.*]] = %[[VAL_4]] to %[[VAL_6]] step %[[VAL_5]] {
// CHECK:                 %[[VAL_26:.*]] = memref.load %[[VAL_14]]{{\[}}%[[VAL_25]], %[[VAL_23]]] : memref<5x6xi64>
// CHECK:                 %[[VAL_27:.*]] = memref.load %[[VAL_7]]{{\[}}%[[VAL_25]], %[[VAL_18]]] : memref<5x3xi8>
// CHECK:                 %[[VAL_28:.*]] = arith.extsi %[[VAL_27]] : i8 to i64
// CHECK:                 %[[VAL_29:.*]] = arith.subi %[[VAL_28]], %[[VAL_3]] : i64
// CHECK:                 %[[VAL_30:.*]] = arith.extsi %[[VAL_24]] : i8 to i64
// CHECK:                 %[[VAL_31:.*]] = arith.muli %[[VAL_29]], %[[VAL_30]] : i64
// CHECK:                 %[[VAL_32:.*]] = arith.addi %[[VAL_26]], %[[VAL_31]] : i64
// CHECK:                 memref.store %[[VAL_32]], %[[VAL_14]]{{\[}}%[[VAL_25]], %[[VAL_23]]] : memref<5x6xi64>
// CHECK:               }
// CHECK:             }
// CHECK:           }
// CHECK:           %[[VAL_33:.*]] = bufferization.to_tensor %[[VAL_14]] : memref<5x6xi64>
// CHECK:           return %[[VAL_33]] : tensor<5x6xi64>
// CHECK:         }
func.func @quantized_matmul(%input1: tensor<5x3xi8>,
                       %input2: tensor<3x6xi8, #DCSR>,
                       %output: tensor<5x6xi64>) -> tensor<5x6xi64> {
  %c0 = arith.constant 0 : i32
  %c2 = arith.constant 2 : i32
  %0 = linalg.quantized_matmul
    ins(%input1, %input2, %c2, %c0 : tensor<5x3xi8>, tensor<3x6xi8, #DCSR>, i32, i32)
    outs(%output : tensor<5x6xi64>) -> tensor<5x6xi64>
  return %0: tensor<5x6xi64>
}

// CHECK-LABEL:   func @sparse_dot(
// CHECK-DAG:       %[[VAL_3:.*]] = arith.constant 0 : index
// CHECK-DAG:       %[[VAL_4:.*]] = arith.constant 1 : index
// CHECK-DAG:       %[[VAL_5:.*]] = sparse_tensor.pointers %[[VAL_0:.*]] {dimension = 0 : index} : tensor<1024xf32, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_6:.*]] = sparse_tensor.indices %[[VAL_0]] {dimension = 0 : index} : tensor<1024xf32, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_7:.*]] = sparse_tensor.values %[[VAL_0]] : tensor<1024xf32, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xf32>
// CHECK-DAG:       %[[VAL_8:.*]] = sparse_tensor.pointers %[[VAL_1:.*]] {dimension = 0 : index} : tensor<1024xf32, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_9:.*]] = sparse_tensor.indices %[[VAL_1]] {dimension = 0 : index} : tensor<1024xf32, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_10:.*]] = sparse_tensor.values %[[VAL_1]] : tensor<1024xf32, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xf32>
// CHECK-DAG:       %[[VAL_11:.*]] = bufferization.to_memref %[[VAL_2:.*]] : memref<f32>
// CHECK-DAG:       %[[VAL_13:.*]] = memref.load %[[VAL_11]][] : memref<f32>
// CHECK-DAG:       %[[VAL_14:.*]] = memref.load %[[VAL_5]]{{\[}}%[[VAL_3]]] : memref<?xindex>
// CHECK-DAG:       %[[VAL_15:.*]] = memref.load %[[VAL_5]]{{\[}}%[[VAL_4]]] : memref<?xindex>
// CHECK-DAG:       %[[VAL_16:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_3]]] : memref<?xindex>
// CHECK-DAG:       %[[VAL_17:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_4]]] : memref<?xindex>
// CHECK:           %[[VAL_18:.*]]:3 = scf.while (%[[VAL_19:.*]] = %[[VAL_14]], %[[VAL_20:.*]] = %[[VAL_16]], %[[VAL_21:.*]] = %[[VAL_13]]) : (index, index, f32) -> (index, index, f32) {
// CHECK:             %[[VAL_22:.*]] = arith.cmpi ult, %[[VAL_19]], %[[VAL_15]] : index
// CHECK:             %[[VAL_23:.*]] = arith.cmpi ult, %[[VAL_20]], %[[VAL_17]] : index
// CHECK:             %[[VAL_24:.*]] = arith.andi %[[VAL_22]], %[[VAL_23]] : i1
// CHECK:             scf.condition(%[[VAL_24]]) %[[VAL_19]], %[[VAL_20]], %[[VAL_21]] : index, index, f32
// CHECK:           } do {
// CHECK:           ^bb0(%[[VAL_25:.*]]: index, %[[VAL_26:.*]]: index, %[[VAL_27:.*]]: f32):
// CHECK:             %[[VAL_28:.*]] = memref.load %[[VAL_6]]{{\[}}%[[VAL_25]]] : memref<?xindex>
// CHECK:             %[[VAL_29:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_26]]] : memref<?xindex>
// CHECK:             %[[VAL_30:.*]] = arith.cmpi ult, %[[VAL_29]], %[[VAL_28]] : index
// CHECK:             %[[VAL_31:.*]] = arith.select %[[VAL_30]], %[[VAL_29]], %[[VAL_28]] : index
// CHECK:             %[[VAL_32:.*]] = arith.cmpi eq, %[[VAL_28]], %[[VAL_31]] : index
// CHECK:             %[[VAL_33:.*]] = arith.cmpi eq, %[[VAL_29]], %[[VAL_31]] : index
// CHECK:             %[[VAL_34:.*]] = arith.andi %[[VAL_32]], %[[VAL_33]] : i1
// CHECK:             %[[VAL_35:.*]] = scf.if %[[VAL_34]] -> (f32) {
// CHECK:               %[[VAL_36:.*]] = memref.load %[[VAL_7]]{{\[}}%[[VAL_25]]] : memref<?xf32>
// CHECK:               %[[VAL_37:.*]] = memref.load %[[VAL_10]]{{\[}}%[[VAL_26]]] : memref<?xf32>
// CHECK:               %[[VAL_38:.*]] = arith.mulf %[[VAL_36]], %[[VAL_37]] : f32
// CHECK:               %[[VAL_39:.*]] = arith.addf %[[VAL_27]], %[[VAL_38]] : f32
// CHECK:               scf.yield %[[VAL_39]] : f32
// CHECK:             } else {
// CHECK:               scf.yield %[[VAL_27]] : f32
// CHECK:             }
// CHECK:             %[[VAL_40:.*]] = arith.cmpi eq, %[[VAL_28]], %[[VAL_31]] : index
// CHECK:             %[[VAL_41:.*]] = arith.addi %[[VAL_25]], %[[VAL_4]] : index
// CHECK:             %[[VAL_42:.*]] = arith.select %[[VAL_40]], %[[VAL_41]], %[[VAL_25]] : index
// CHECK:             %[[VAL_43:.*]] = arith.cmpi eq, %[[VAL_29]], %[[VAL_31]] : index
// CHECK:             %[[VAL_44:.*]] = arith.addi %[[VAL_26]], %[[VAL_4]] : index
// CHECK:             %[[VAL_45:.*]] = arith.select %[[VAL_43]], %[[VAL_44]], %[[VAL_26]] : index
// CHECK:             scf.yield %[[VAL_42]], %[[VAL_45]], %[[VAL_46:.*]] : index, index, f32
// CHECK:           }
// CHECK:           memref.store %[[VAL_47:.*]]#2, %[[VAL_11]][] : memref<f32>
// CHECK:           %[[VAL_48:.*]] = bufferization.to_tensor %[[VAL_11]] : memref<f32>
// CHECK:           return %[[VAL_48]] : tensor<f32>
// CHECK:         }
func.func @sparse_dot(%a: tensor<1024xf32, #SparseVector>,
                 %b: tensor<1024xf32, #SparseVector>,
		 %x: tensor<f32>) -> tensor<f32> {
  %dot = linalg.dot ins(%a, %b: tensor<1024xf32, #SparseVector>,
                                tensor<1024xf32, #SparseVector>)
                   outs(%x: tensor<f32>) -> tensor<f32>
  return %dot : tensor<f32>
}
