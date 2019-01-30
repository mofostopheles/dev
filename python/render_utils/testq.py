#!/usr/bin/env python
# -*- coding: utf8 -*-

from questionnaire import Questionnaire

# ask the user what kind of sprites they want to make

# ultimately we will gather the answers to these questions and fire off on of the following scripts
# make_sprites_from_frames.py
# make_sprites_from_sequences.py

q = Questionnaire()
q.one('Kind of sprite to make:', 'frame style', 'straight sequence to sprite')

q.many('Attributes', 'JPG', 'PNG', 'write code').condition(('time', 'night'))


# how to do conditionals:
# q = Questionnaire()
# q.one('day', 'monday', 'friday', 'saturday')
# q.one('time', 'morning', 'night')

# q.many('activities', 'tacos de pastor', 'go to cantina', 'write code').condition(('time', 'night'))
# q.many('activities', 'barbacoa', 'watch footy', 'walk dog').condition(('day', 'saturday'), ('time', 'morning'))
# q.many('activities', 'eat granola', 'get dressed', 'go to work').condition(('time', 'morning'))

# q.run()
# print(q.format_answers(fmt='array'))



q.run()
print(q.format_answers(fmt='array'))