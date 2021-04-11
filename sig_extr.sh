#!/bin/bash

for file in `ls ./input/`
do
    
    rm ./output/case_*
    rm ./output/pre_step_*
    rm ./output/step_*
    rm ./output/count_*
    cp ./count_100 ./output
    
    echo "processing...." $file
    #prevent empty perfect step so the count_100 is a place holder
    cp ./input/$file joyce.txt

    name=`echo $file | sed 's/\.txt//'`
    
    for i in `seq 1 82`
    do
	j=`expr $i + 1`
	for k in `seq 0 9`
	do
	    #print out the most effect brain cut out section for each cases
	    cat joyce.txt | tr -d \[\]\"\' | cut -f1,$j | awk -F '\t' '{t=$1; $1=$2; $2=t; print}' | sort -g | grep -E "[0-9] ([LR]_[0-9a-zA-Z-]*, ){"$k"}[LR]_[0-9a-zA-Z-]*$" | head -$1 >> ./output/case_${i}
	    #print out unsorted raw data for each case with set identifier 0-9
	    cat joyce.txt | tr -d \[\]\"\' | cut -f1,$j | awk -F '\t' '{t=$1; $1=$2; $2=t; print}' | sort -gr | grep -E "[0-9] ([LR]_[0-9a-zA-Z-]*, ){"$k"}[LR]_[0-9a-zA-Z-]*$" | sed 's/^/'$k' /' | awk -F ' ' '{t=$1; $1=$2; $2=t; print}' | sort -gr >> ./output/pre_step_${i}
	done
	#print out the step map for non-step detection
	cat ./output/pre_step_${i} | sort -gr | cut -d " " -f2 | tr "\n" "," > ./output/step_${i}
    done
    
    #to find out detail of the non-step set
    # e.g.     
    # cat  ./output/count_2 shows non_step2: 1
    # therefore                           ^  ^
    # cat ./output/pre_step_2 | sort -gr | grep -E "[0-9] ([LR]_[0-9a-zA-Z-]*, ){2}[LR]_[0-9a-zA-Z-]*$" | head -1
    #                                                                            ^                              ^
    # will show the 1 result of that non-step because it is always the top case that trigger the nonsteping
    
    for i in `seq 1 80`
    do
	#print out non-step happen case
	cp ./output/step_${i} ./test.csv
	./test > ./output/count_${i}
    done
    
    #generate perfect (step brain), partial (almost step brain) and nonstep (rest of the cases)
    pushd output
    grep -HR "non_step"  | sed 's/count_.*:non_step.:/,/' | tr -d "\n" | sed 's/count_[0-9]*:non_step10/ &,\n/g' | sed 's/:.*,//' > ../csv/${name}_step.csv
    echo " 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 count_100" >> ../csv/${name}_step.csv
    grep -HR "non_step"  | sed 's/count_.*:non_step.:/,/' | tr -d "\n" | sed 's/count_[0-9]*:non_step10/ &,\n/g' | sed 's/:.*,//' | grep "0, 0, 0, 0, 0, 0, 0, 0, 0," > ../csv/${name}_perfect.csv
    echo " 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 count_100" >> ../csv/${name}_perfect.csv
    grep -HR "non_step"  | sed 's/count_.*:non_step.:/,/' | tr -d "\n" | sed 's/count_[0-9]*:non_step10/ &,\n/g' | sed 's/:.*,//' | grep "0, 0, 0, 0, 0, [1-9][0-9]*," > ../csv/${name}_partial.csv
    echo " 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 count_100" >> ../csv/${name}_partial.csv
    #grep -HR "non_step"  | sed 's/count_.*:non_step.:/,/' | tr -d "\n" | sed 's/count_[0-9]*:non_step10,/ &\n/g' | sed 's/:.*,//' | grep "[1-9][0-9]*, [1-9][0-9]*, [1-9][0-9]*, [1-9][0-9]*, [1-9][0-9]*," > ../csv/${name}_nonstep.csv
    #grep -HR "non_step"  | sed 's/count_.*:non_step.:/,/' | tr -d "\n" | sed 's/count_[0-9]*:non_step10/ &,\n/g' | sed 's/:.*,//' | grep "[1-9][0-9]*, [1-9][0-9]*, [1-9][0-9]*, [1-9][0-9]*, [1-9][0-9]*," > ../csv/${name}_nonstep.csv
    grep -HR "non_step"  | sed 's/count_.*:non_step.:/,/' | tr -d "\n" | sed 's/count_[0-9]*:non_step10/ &,\n/g' | sed 's/:.*,//' | grep -v "0, 0, 0, 0, 0, [1-9][0-9]*," | grep -v "0, 0, 0, 0, 0, 0, 0, 0, 0," > ../csv/${name}_nonstep.csv
    echo " 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 count_100" >> ../csv/${name}_nonstep.csv
    popd
    
    # is the non-stepping top 5 same as stepwise top 5?
    # run both seperately

    for i in `seq 0 9`
    do
	j=`expr $i + 1`
	#print out the top effect brain cut out for each set in all cases
	cat ./output/case_* | cut -d " " --complement -f1 | grep -E "^[LR]_[0-9a-zA-Z-]*(, [LR]_[0-9a-zA-Z-]*){"$i"}$" | sort | uniq -c | sort -gr > ./output/${name}_set_${j}
	pushd output
	cat `cat ../csv/${name}_perfect.csv | cut -d " " -f 12 | tr "\n" " " | sed 's/count_/case_/g'` | cut -d " " --complement -f1 | grep -E "^[LR]_[0-9a-zA-Z-]*(, [LR]_[0-9a-zA-Z-]*){"$i"}$" | sort | uniq -c | sort -gr > ./${name}_perfect_set_${j}
	cat `cat ../csv/${name}_partial.csv | cut -d " " -f 12 | tr "\n" " " | sed 's/count_/case_/g'` | cut -d " " --complement -f1 | grep -E "^[LR]_[0-9a-zA-Z-]*(, [LR]_[0-9a-zA-Z-]*){"$i"}$" | sort | uniq -c | sort -gr > ./${name}_partial_set_${j}
	cat `cat ../csv/${name}_nonstep.csv | cut -d " " -f 12 | tr "\n" " " | sed 's/count_/case_/g'` | cut -d " " --complement -f1 | grep -E "^[LR]_[0-9a-zA-Z-]*(, [LR]_[0-9a-zA-Z-]*){"$i"}$" | sort | uniq -c | sort -gr > ./${name}_nonstep_set_${j}
	popd
    done

    pushd output
    cat ${name}_set_* > ${name}_set
    cat ${name}_perfect_set_* > ${name}_perfect_set
    cat ${name}_partial_set_* > ${name}_partial_set
    cat ${name}_nonstep_set_* > ${name}_nonstep_set
    popd
    
done #done all files
