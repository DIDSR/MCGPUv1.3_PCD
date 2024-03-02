
##
## 01/04/2024
##
## An example script to create phantoms using phantom class.
###########################################################################

################################
## Import packages
################################ 
from phantom import Phantom
import os

################################
## Define constants / defaults
################################


################################
## Define functions
################################
def two_iodine_phantoms (step_by_step=False):

    voxelSize = [0.01, 0.01, 1.0]
    numVoxels = [100, 100, 1]
    outpath = 'plots/twoIodine/'

    # Create a cubic air background
    aphantom = Phantom (voxelSize, numVoxels)
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'backgroundAir.png')

    # Create water cylinder
    center = [0.5, 0.5, 0.5]
    radius, height = 0.5, 0.8
    aphantom.addCylinder (center, radius, height, 'water')
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'waterOnly.png')

    # Insert one iodine 2.0 cylinder
    center = [0.75, 0.5, 0.5]
    radius, height = 0.1, 0.8
    aphantom.addCylinder (center, radius, height, '2.0Iodine')
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'2.0IodineOnly.png')

    # Insert another iodine 10.0 cylinder
    center = [0.25, 0.5, 0.5]
    radius, height = 0.1, 0.8
    aphantom.addCylinder (center, radius, height, '10.0Iodine')
    aphantom.plotPhantom (filename=outpath+'myPhantom.png')

    aphantom.writeVoxFile('twoIodineCylinders.vox')

def sphere_phantoms (step_by_step=False):

    voxelSize = [0.0625, 0.0625, 0.0625]
    numVoxels = [16, 16, 16]
    voxelSizeFactors=[4, 4, 4]
    alpha = 0.3
    outpath = 'plots/sphere/'

    # Create a cubic air background
    aphantom = Phantom (voxelSize, numVoxels)
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'backgroundAir.png')

    # Create water sphere
    center = [0.5, 0.5, 0.5]
    radius = 0.5
    aphantom.addSphere (center, radius, 'water')
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'waterOnly.png',
                              voxelSizeFactors=voxelSizeFactors, alpha=alpha)

    # Insert one iodine 2.0 cylinder
    center = [0.75, 0.75, 0.75]
    radius = 0.1
    aphantom.addSphere (center, radius, '2.0Iodine')
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'2.0IodineOnly.png',
                              voxelSizeFactors=voxelSizeFactors, alpha=alpha)

    # Insert another iodine 10.0 cylinder
    center = [0.25, 0.25, 0.25]
    radius = 0.1
    aphantom.addSphere (center, radius, '10.0Iodine')
    aphantom.plotPhantom (filename=outpath+'myPhantom.png',
                          voxelSizeFactors=voxelSizeFactors, alpha=alpha)

    aphantom.writeVoxFile('sphere.vox')

def sphere_cylinder_phantoms (step_by_step=False):

    voxelSize = [0.05, 0.05, 0.05]
    numVoxels = [20, 20, 20]
    voxelSizeFactors=[2, 2, 2]
    alpha = 0.3    
    outpath = 'plots/sphere_cylinder/'

    # Create a cubic air background
    aphantom = Phantom (voxelSize, numVoxels)
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'backgroundAir.png',
                              voxelSizeFactors=voxelSizeFactors, alpha=alpha)

    # Create water sphere
    center = [0.5, 0.5, 0.5]
    radius, height = 0.5, 1.0
    aphantom.addCylinder (center, radius, height, 'water')
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'waterOnly.png',
                              voxelSizeFactors=voxelSizeFactors, alpha=alpha)

    # Insert one iodine 2.0 cylinder
    center = [0.75, 0.75, 0.75]
    radius = 0.1
    aphantom.addSphere (center, radius, '2.0Iodine')
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'2.0IodineOnly.png',
                              voxelSizeFactors=voxelSizeFactors, alpha=alpha)

    # Insert another iodine 10.0 cylinder
    center = [0.25, 0.5, 0.5]
    radius, height = 0.1, 1.0
    aphantom.addCylinder (center, radius, height, '10.0Iodine')
    aphantom.plotPhantom (filename=outpath+'myPhantom.png',
                          voxelSizeFactors=voxelSizeFactors, alpha=alpha)

    aphantom.writeVoxFile('sphere_cylinder.vox')

def caffeine_cylinder_phantoms (step_by_step=False, caffeine_only=False, water_only=False):

    name = 'combined'
    if caffeine_only: name = 'caffeine_only'
    if water_only: name = 'water_only' 

    voxelSize = [0.16, 0.16, 20.0] #cm
    numVoxels = [100, 100, 1]
    outpath = 'plots/' + name + '/'
    if not os.path.exists (outpath): os.mkdir (outpath)

    # Create a cubic air background
    aphantom = Phantom (voxelSize, numVoxels)
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'backgroundAir.png')

    # Create water cylinder
    center = [8.0, 8.0, 10.0]
    radius, height = 8.0, 20.0
    material = 'water'
    if caffeine_only: material = 'air'
    aphantom.addCylinder (center, radius, height, material)
    if step_by_step:
        aphantom.plotPhantom (filename=outpath+'basePhantomOnly.png')

    # Insert one caffeine cylinder
    center = [8.0, 8.0, 10.0]
    radius, height = 2.5, 20.0
    material = 'caffeine'
    if water_only: material = 'water'
    aphantom.addCylinder (center, radius, height, material)
    aphantom.plotPhantom (filename=outpath+'full.png')

    aphantom.writeVoxFile(name + '.vox')


################################
## Main
################################
if __name__ == '__main__':

    #two_iodine_phantoms (step_by_step=True)
    #sphere_phantoms (step_by_step=True)
    #sphere_cylinder_phantoms (step_by_step=True)
    caffeine_cylinder_phantoms (step_by_step=True)
    caffeine_cylinder_phantoms (step_by_step=True, caffeine_only=True, water_only=False)
    caffeine_cylinder_phantoms (step_by_step=True, caffeine_only=False, water_only=True)
