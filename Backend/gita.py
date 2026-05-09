import os
import random
import linecache
import time

global edge
def page(filename,rand):
    for i in range(rand,1078+1):
        line=linecache.getline(filename,i)

        if "The Supreme Personality of Godhead said:" in line:
                start=i
                current_idx=i
                while True:
                    segment=linecache.getline(filename,current_idx)
                    if not segment.strip(): #if the line is empty or contains only whitespace, we consider it as the end of the section
                        edge=current_idx-1
                        break
                    current_idx+=1
                between=random.randint(start,edge)
                chosen=linecache.getline(filename,between)
                print(f"{between}:"+chosen.rstrip())
                time.sleep(0.5)    
                return chosen.rstrip()
                # while True:
                #     segment=linecache.getline(filename,current_idx)
                #     if not segment.strip():
                #           break
                #     print(segment.rstrip())
                #     time.sleep(0.5)
                #     current_idx+=1
                break
        # else:
        #      page(filename,0)
        #      break
     
if __name__=="__main__":
    
    rand=random.randint(1,1078)
    filename="TheHolyGita.txt"
    page(filename,rand)
    
			
			
			