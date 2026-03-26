#include <cstddef>
#include <concepts>
#include <utility>
#include <cstdint>
#include <limits>
#include <iterator>
#include <cassert>
#include <stdexcept>
#include <memory>

template<typename T, std::size_t Capacity = 64>
class static_vector{
    public:
    static_assert(Capacity != 0, "static_vector cannot have 0 capacity");

    /* CONSTRUCTORS */
    constexpr static_vector() noexcept : m_size(0){}

    explicit constexpr static_vector(std::size_t count, const T& value = T()) requires std::copy_constructible<T>
        : m_size(0){
        resize(count, value);
    }


    /* SPECIAL MEMBER FUNCTIONS */
    constexpr ~static_vector() noexcept(std::is_nothrow_destructible_v<T>){
        clear();
    }

    constexpr static_vector(const static_vector& other) requires std::copy_constructible<T> : m_size(0){
        for(std::size_t i = 0; i < other.size(); i++){
            push_back(other[i]);
        }
    }

    constexpr static_vector(static_vector&& other)
        noexcept(std::is_nothrow_move_constructible_v<T> && std::is_nothrow_destructible_v<T>)
        requires std::move_constructible<T> : m_size(0){
        for(std::size_t i = 0; i < other.size(); i++){
            push_back(std::move(other[i]));
        }
        other.clear();
    }

    constexpr static_vector& operator=(const static_vector& other) requires std::copy_constructible<T>{
        if(this != std::addressof(other)){
            clear();

            for(std::size_t i = 0; i < other.size(); i++){
                push_back(other[i]);
            }
        }

        return *this;
    }

    constexpr static_vector& operator=(static_vector&& other)
        noexcept(std::is_nothrow_move_constructible_v<T> && std::is_nothrow_destructible_v<T>)
        requires std::move_constructible<T>{
        if(this != std::addressof(other)){
            clear();

            for(std::size_t i = 0; i < other.size(); i++){
                push_back(std::move(other[i]));
            }

            other.clear();
        }

        return *this;
    }


    /* ELEMENT ACCESS */
    [[nodiscard]] constexpr T& at(std::size_t index){
        if(index >= size()){
            throw std::out_of_range("Index out of range");
        }

        return data()[index];
    }

    [[nodiscard]] constexpr const T& at(std::size_t index) const{
        if(index >= size()){
            throw std::out_of_range("Index out of range");
        }

        return data()[index];
    }

    [[nodiscard]] constexpr T& operator[](std::size_t index) noexcept{
        assert(index < size());
        return data()[index];
    }

    [[nodiscard]] constexpr const T& operator[](std::size_t index) const noexcept{
        assert(index < size());
        return data()[index];
    }

    [[nodiscard]] constexpr T& front() noexcept{
        assert(!empty());
        return data()[0];
    }

    [[nodiscard]] constexpr const T& front() const noexcept{
        assert(!empty());
        return data()[0];
    }

    [[nodiscard]] constexpr T& back() noexcept{
        assert(!empty());
        return data()[size() - 1];
    }

    [[nodiscard]] constexpr const T& back() const noexcept{
        assert(!empty());
        return data()[size() - 1];
    }

    [[nodiscard]] constexpr T* data() noexcept{
        return m_data;
    }

    [[nodiscard]] constexpr const T* data() const noexcept{
        return m_data;
    }


    /* ITERATORS */
    [[nodiscard]] constexpr auto begin() noexcept{
        return data();
    }

    [[nodiscard]] constexpr auto begin() const noexcept{
        return data();
    }

    [[nodiscard]] constexpr auto cbegin() const noexcept{
        return data();
    }

    [[nodiscard]] constexpr auto end() noexcept{
        return data() + size();
    }

    [[nodiscard]] constexpr auto end() const noexcept{
        return data() + size();
    }

    [[nodiscard]] constexpr auto cend() const noexcept{
        return data() + size();
    }

    [[nodiscard]] constexpr auto rbegin() noexcept{
        return std::make_reverse_iterator(end());
    }

    [[nodiscard]] constexpr auto rbegin() const noexcept{
        return std::make_reverse_iterator(end());
    }

    [[nodiscard]] constexpr auto crbegin() const noexcept{
        return std::make_reverse_iterator(cend());
    }

    [[nodiscard]] constexpr auto rend() noexcept{
        return std::make_reverse_iterator(begin());
    }

    [[nodiscard]] constexpr auto rend() const noexcept{
        return std::make_reverse_iterator(begin());
    }

    [[nodiscard]] constexpr auto crend() const noexcept{
        return std::make_reverse_iterator(cbegin());
    }


    /* CAPACITY */
    [[nodiscard]] constexpr bool empty() const noexcept{
        return size() == 0;
    }

    [[nodiscard]] constexpr std::size_t size() const noexcept{
        return m_size;
    }

    [[nodiscard]] constexpr std::size_t max_size() const noexcept{
        return Capacity;
    }

    [[nodiscard]] constexpr std::size_t capacity() const noexcept{
        return Capacity;
    }


    /* MODIFIERS */
    constexpr void clear() noexcept(std::is_nothrow_destructible_v<T>){
        while(!empty()){
            pop_back();
        }
    }

    constexpr void push_back(const T& value)
        noexcept(std::is_nothrow_copy_constructible_v<T>)
        requires std::copy_constructible<T>{
        assert(size() < capacity());
        emplace_back(value);
    }

    constexpr void push_back(T&& value)
        noexcept(std::is_nothrow_move_constructible_v<T>)
        requires std::move_constructible<T>{
        assert(size() < capacity());
        emplace_back(std::move(value));
    }

    template<typename... Args>
    constexpr T& emplace_back(Args&&... args) noexcept(std::is_nothrow_constructible_v<T, Args...>){
        assert(size() < capacity());
        T* ptr = std::construct_at(data() + size(), std::forward<Args>(args)...);
        m_size++;
        return *ptr;
    }

    constexpr void pop_back() noexcept(std::is_nothrow_destructible_v<T>){
        assert(!empty());
        std::destroy_at(data() + size() - 1);
        m_size--;
    }

    constexpr void resize(std::size_t count) requires std::default_initializable<T>{
        assert(count <= capacity());
        while(m_size > count){
            pop_back();
        }

        while(m_size < count){
            emplace_back();
        }
    }

    constexpr void resize(std::size_t count, const T& value) requires std::copy_constructible<T>{
        assert(count <= capacity());
        while(m_size > count){
            pop_back();
        }

        while(m_size < count){
            push_back(value);
        }
    }

    private:
    union { T m_data[Capacity]; };
    std::uint8_t m_size;
};
