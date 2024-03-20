##
## 01/03/2024
##
## This script encapsulates the functions to build a simple phantom.
###########################################################################

################################
## Import packages
################################
from decimal import Decimal
import math

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

################################
## Define constants / defaults
################################
## voxel size [x, y, z] in cm
voxelSize = [0.01, 0.01, 20]

## number of voxels in the phantom
noVoxels = [100, 100, 1]

## material for the background cube
backgroundMaterial = "air"

## materials: <name>: {<ID>, <mass density>, <color for plots>, <file path>}
## The ID and file path must match the material section in .in file
materials = {
    "air": {
        "ID": 1,
        "density": 0.0012,
        "color": "white",
        "filePath": "MCGPUmaterial/air.mcgpu",
    },
    "water": {
        "ID": 2,
        "density": 1.0,
        "color": "midnightblue",
        "filePath": "MCGPUmaterial/water.mcgpu",
    },
    "caffeine": {
        "ID": 3,
        "density": 1.23,
        "color": "brown",
        "filePath": "MCGPUmaterial/caffeine/caffeineMIF_1.23_narrow_5_150keV.mcgpu",
    },
    "2.0Iodine": {
        "ID": 4,
        "density": 1.00015943,
        "color": "orange",
        "filePath": "MCGPUmaterial/2.0Iodine_5-200keV.mcgpu",
    },
    "10.0Iodine": {
        "ID": 5,
        "density": 1.00398580,
        "color": "yellow",
        "filePath": "MCGPUmaterial/10.0Iodine_5-200keV.mcgpu",
    },
}

################################
## Short functions
################################


################################
## Define phantom class
################################
class Phantom(object):
    def __init__(self, voxelSize, numVoxels, backgroundMaterial="air"):
        """ """

        self.voxelSize = voxelSize
        self.numVoxels = numVoxels
        self.backgroundMaterial = backgroundMaterial

        self._digitalPhantom = self.BuildBackgroundCube()

    @property
    def voxelSize(self):
        return self._voxelSize

    @voxelSize.setter
    def voxelSize(self, voxelSize):
        self._check_voxelsize(voxelSize)
        self._voxelSize = voxelSize

    @property
    def numVoxels(self):
        return self._numVoxels

    @numVoxels.setter
    def numVoxels(self, numVoxels):
        self._check_numVoxels(numVoxels)
        self._numVoxels = numVoxels

    @property
    def backgroundMaterial(self):
        return self._backgroundMaterial

    @backgroundMaterial.setter
    def backgroundMaterial(self, backgroundMaterial):
        self._check_material(backgroundMaterial)
        self._backgroundMaterial = backgroundMaterial

    @property
    def digitalPhantom(self):
        return np.array(self._digitalPhantom)

    def _check_voxelsize(self, voxelSize):
        self._check_voxels("voxel size", voxelSize)

    def _check_numVoxels(self, numVoxels):
        self._check_voxels("number of voxels", numVoxels)

    def _check_voxels(self, infoname, voxelinfo):
        voxelx, voxely, voxelz = voxelinfo
        atype = float if infoname == "voxel size" else int
        atypename = "a float" if infoname == "voxel size" else "wn int"
        if voxelx <= 0 or type(voxelx) != atype:
            raise ValueError(
                "Error: {0} in x-axis must be greater than zero and {1}".format(
                    infoname, atypename
                )
            )
        elif voxely <= 0 or type(voxely) != atype:
            raise ValueError(
                "Error: {0} in y-axis must be greater than zero and {1}".format(
                    infoname, atypename
                )
            )
        elif voxelz <= 0 or type(voxelz) != atype:
            raise ValueError(
                "Error: {0} in z-axis must be greater than zero and {1}".format(
                    infoname, atypename
                )
            )

    def _check_material(self, material):
        if not material in materials.keys():
            raise ValueError(
                "Error: Invalid material {0}. Please provide one of the followings: {1}".format(
                    material, materials.keys()
                )
            )

    def BuildBackgroundCube(self):
        """Private function to build the background cube."""

        numVoxelsX, numVoxelsY, numVoxelsZ = self._numVoxels
        material = self._backgroundMaterial

        voxel = []
        for z in range(0, numVoxelsZ):
            helperArray = []
            for y in range(0, numVoxelsY):
                helperArray2 = []
                for x in range(0, numVoxelsX):
                    helperArray2.append(materials[material]["ID"])
                helperArray.append(helperArray2)
            voxel.append(helperArray)

        return voxel

    def reset(self, voxelSize, numVoxels, backgroundMaterial="air"):
        self.voxelSize = voxelSize
        self.numVoxels = numVoxels
        self.backgroundMaterial = backgroundMaterial

        self._digitalPhantom = self.BuildBackgroundCube()

    # Builds a cylindrical object
    def addCylinder(self, centers, radius, height, material):
        self._check_material(material)
        numVoxelsX, numVoxelsY, numVoxelsZ = self._numVoxels
        voxelSizeX, voxelSizeY, voxelSizeZ = self._voxelSize
        centerX, centerY, centerZ = centers

        halfHeight = height / 2

        for z in range(0, numVoxelsZ):
            for y in range(0, numVoxelsY):
                for x in range(0, numVoxelsX):
                    trueX = (x * voxelSizeX) + (voxelSizeX / 2)
                    trueY = (y * voxelSizeY) + (voxelSizeY / 2)
                    trueZ = (z * voxelSizeZ) + (voxelSizeZ / 2)
                    # check if x and y are within the radius
                    if (
                        math.sqrt(((trueX - centerX) ** 2) + ((trueY - centerY) ** 2))
                        < radius
                    ):
                        # check if z is within the height
                        if abs(trueZ - centerZ) < halfHeight:
                            self._digitalPhantom[z][y][x] = materials[material]["ID"]

    # Builds a spherical object
    def addSphere(self, centers, radius, material):
        self._check_material(material)
        numVoxelsX, numVoxelsY, numVoxelsZ = self._numVoxels
        voxelSizeX, voxelSizeY, voxelSizeZ = self._voxelSize
        centerX, centerY, centerZ = centers

        for z in range(0, numVoxelsZ):
            for y in range(0, numVoxelsY):
                for x in range(0, numVoxelsX):
                    trueX = (x * voxelSizeX) + (voxelSizeX / 2)
                    trueY = (y * voxelSizeY) + (voxelSizeY / 2)
                    trueZ = (z * voxelSizeZ) + (voxelSizeZ / 2)

                    # check if x and y and z are within the radius from the center coordinates
                    if (
                        math.sqrt(
                            ((trueX - centerX) ** 2)
                            + ((trueY - centerY) ** 2)
                            + ((trueZ - centerZ) ** 2)
                        )
                        < radius
                    ):
                        self._digitalPhantom[z][y][x] = materials[material]["ID"]

    def writeVoxFile(self, filename):
        numVoxelsX, numVoxelsY, numVoxelsZ = self._numVoxels
        voxelSizeX, voxelSizeY, voxelSizeZ = self._voxelSize
        massDensities = [
            value["density"]
            for _, value in dict(
                sorted(materials.items(), key=lambda x: x[1]["ID"])
            ).items()
        ]

        with open(filename, "w") as fp:
            fp.write(
                "# HEADER section: voxel geometry file generated by example_phantom_generator.py\n"
            )
            fp.write("[SECTION VOXELS HEADER v.2008-04-13]\n")

            # Number of Voxels
            fp.write(
                "{0} {1} {2} No. OF VOXELS IN X,Y,Z\n".format(
                    numVoxelsX, numVoxelsY, numVoxelsZ
                )
            )

            # Voxel Size
            fp.write(
                "{0} {1} {2} VOXEL SIZE (cm) ALONG X,Y,Z\n".format(
                    voxelSizeX, voxelSizeY, voxelSizeZ
                )
            )

            fp.write(" 1                  COLUMN NUMBER WHERE MATERIAL ID IS LOCATED\n")
            fp.write(
                " 2                  COLUMN NUMBER WHERE THE MASS DENSITY IS LOCATED\n"
            )
            fp.write(
                " 1                  BLANK LINES AT END OF X,Y-CYCLES (1=YES,0=NO)\n"
            )
            fp.write(
                "[END OF VXH SECTION]  # MCGPU-PET voxel format: Material  Density  Activity\n"
            )

            for z in self.digitalPhantom:
                for y in z:
                    for x in y:
                        fp.write(str(x) + " " + str(massDensities[x - 1]) + "\n")
                    fp.write("\n")
                fp.write("\n")

    def plotPhantom(
        self, filename="phantom.png", voxelSizeFactors=[1, 1, 1], alpha=0.7
    ):
        numVoxelsX, numVoxelsY, numVoxelsZ = self._numVoxels
        voxelSizeX, voxelSizeY, voxelSizeZ = self._voxelSize
        colors = [
            value["color"]
            for _, value in dict(
                sorted(materials.items(), key=lambda x: x[1]["ID"])
            ).items()
        ]

        dx = voxelSizeX * voxelSizeFactors[0]
        dy = voxelSizeY * voxelSizeFactors[1]
        dz = voxelSizeZ * voxelSizeFactors[2]

        fig = plt.figure()
        ax = fig.add_subplot(111, projection="3d")

        for z in range(0, numVoxelsZ):
            for y in range(0, numVoxelsY):
                for x in range(0, numVoxelsX):
                    material = self.digitalPhantom[z][y][x]
                    color = colors[material - 1]
                    ax.bar3d(x, y, z, dx, dy, dz, color=color, alpha=alpha)

        # Set labels and title
        ax.set_xlabel("X")
        ax.set_ylabel("Y")
        ax.set_zlabel("Z")
        ax.set_title("3D Cube Plot")

        # Show the plot
        plt.savefig(filename)
