from mcpi import minecraft
import math
import random

mc = minecraft.Minecraft.create()
mc.postToChat('hello maria')

x, y, z = mc.player.getPos()


for x1 in range(0, 100):
        mc.setBlock(x-x1, 3, z, 60)
        mc.setBlock(x-x1, 3, z+1, 60)
