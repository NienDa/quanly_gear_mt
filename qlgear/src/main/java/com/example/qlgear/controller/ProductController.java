package com.example.qlgear.controller;

import com.example.qlgear.entity.Category;
import com.example.qlgear.entity.Product;
import com.example.qlgear.entity.User;
import com.example.qlgear.service.OrderService;
import com.example.qlgear.service.ProductService;
import com.example.qlgear.service.CategoryService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class ProductController {
    private final ProductService service;
    private final CategoryService serviceCate;
    private final OrderService serviceOrder;
    public ProductController(OrderService serviceOrder,ProductService service,CategoryService serverCate){
        this.service=service;
        this.serviceCate=serverCate;
        this.serviceOrder=serviceOrder;
    }
    @GetMapping("/home")
    public String home(){
        return "home";
    }
    @GetMapping("/")
    public String customerHome(Model model){

        model.addAttribute(
                "products",
                service.getAllProducts()
        );

        model.addAttribute(
                "categories",
                serviceCate.getAllCategory()
        );

        return "kh_home";
    }
    //view list sp
    @GetMapping("/products")
    public String list(Model model){
        model.addAttribute("listsp",service.getAllProducts());
        return "products";
    }
    //them sp
    @GetMapping("/add")
    public String add(Model model){
        model.addAttribute("product",new Product());
        model.addAttribute("categories", serviceCate.getAllCategory());
        return "/add";
    }
    //save sp
    @PostMapping("/add/save")
    public String savesp(@ModelAttribute Product product){
        service.addProduct(product);
        return "redirect:/products";
    }
    //edit form
    @GetMapping("/edit/{id}")
    public String edit(Model model, @PathVariable Long id){
        model.addAttribute("sp",service.getProductById(id));
        model.addAttribute("categories",serviceCate.getAllCategory());
        return "edit-sp";
    }
    //update edit
    @PostMapping("/update/{id}")
    public String upd_sp(@ModelAttribute Product sp,@PathVariable Long id){
        service.updateProduct(id,sp);
        return "redirect:/products";
    }
    //del
    @GetMapping("/del/{id}")
    public String del(@PathVariable Long id){
        service.deleteProduct(id);
        return "redirect:/products";
    }
    //buy pd
    @GetMapping("/buy/{id}")
    public String buy(

            @PathVariable Long id,

            HttpSession session

    ) {
        User user =
                (User) session.getAttribute("user");
        Product product = service.getProductById(id);

        serviceOrder.buy_SP(
                user,
                product
        );
        return "redirect:/products";
    }
}
