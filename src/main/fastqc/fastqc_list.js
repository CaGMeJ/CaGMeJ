var page=document.getElementById("page");
var right=document.getElementById("right");
var left=document.getElementById("left");
var table=document.getElementById("table");
var update=function(page_number){
  for(var i=1;i<table.rows.length;i++){
      var row=table.rows[i];
      for(var j=0;j<row.cells.length;j++){
      var cell=row.cells[j];
      if(i-1+page_number*per_page<file_list.length){
       cell.innerHTML=file_list[i-1+page_number*per_page][j];
      }
      else cell.innerHTML="";
      }
  }
};
var max_page=Math.ceil(file_list.length/per_page);
right.addEventListener("click",() => {
  var page_number=Number(page.innerText);
  page_number=Math.min(page_number+1,max_page);
  page.innerText=page_number;
  update(page_number-1);
});
left.addEventListener("click",() => {
  var page_number=Number(page.innerText);
  page_number=Math.max(page_number-1,1);
  page.innerText=page_number;
  update(page_number-1);
});
